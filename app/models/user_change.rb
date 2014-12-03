# TODO: рефакторинг. перевод на на state_machine, использовать STI, разные классы для правок текста, видео, скриншотов
class UserChange < ActiveRecord::Base
  # TODO: rename to "Contribution"
  ScreenshotsPosition = "screenshots_position"
  ScreenshotsUpload = "screenshots_upload"
  ScreenshotsDeletion = "screenshots_deletion"

  VideoUpload = "video_upload"
  VideoDeletion = "video_deletion"

  include HTMLDiff
  include ActionView::Helpers::SanitizeHelper

  belongs_to :user
  belongs_to :approver, class_name: User.name, foreign_key: :approver_id

  validates_numericality_of :user_id
  validates_numericality_of :item_id
  validates_presence_of :model
  #validates_presence_of :column
  #validates_presence_of :value

  before_create :release_lock

  class << self
    # число не принятых изменений
    def pending_count
      UserChange.where(status: UserChangeStatus::Pending).count
    end

    # есть ли не прнятые изменения
    def has_changes?
      pending_count > 0
    end
  end

  def current_prior
    return @current_prior if defined?(@current_prior)
    klass = Object.const_get(self.model.capitalize.to_sym)
    item = klass.find(self.item_id)

    @current_prior = if item[self.column].blank? && description? && item['description_mal'] != nil
      item['description_mal']

    elsif item[self.column].blank? && description? && item['description_mal'] != nil
      item['description_mal']

    elsif item[self.column].blank? && description? && item['ani_db_description'] != nil
      item['ani_db_description']

    elsif item[self.column].blank? && self.column == 'russian'
      ''

    elsif item[self.column].blank? && self.column == 'torrents_name'
      ''

    else
      item[self.column]
    end
  end

  def item
    @item ||= Object.const_get(self.model.capitalize.to_sym).find_by_id self.item_id
  end

  def get_diff
    diff(prior.present? ? prior : (current_prior || ''), value)
  end

  def pending?
    status == UserChangeStatus::Pending
  end

  # скриншоты отсортированные
  def positioned_screenshots(order=value)
    raise RuntimeError.new("Column is #{column}, but expected 'screenshots'") unless column == 'screenshots'
    raise RuntimeError.new("Action is #{action}, but expected '#{ScreenshotsPosition}'") unless action == ScreenshotsPosition

    screenshots = item.screenshots.each_with_object({}) do |v,rez|
      rez[v.id] = v
    end
    order.split(',').map(&:to_i).map {|id| screenshots[id] }.compact
  end

  # изменение ли это скриншотов
  def screenshots?
    column == 'screenshots'
  end

  # изменение ли это видео
  def video?
    column == 'video'
  end

  # изменение ли это описания
  def description?
    column == 'description'
  end

  def deny approver_id, is_rejected
    self.approver_id = approver_id

    # для скриншотов спец логика
    if screenshots?
      if action == ScreenshotsPosition
        deny_screenshots_positions
      elsif action == ScreenshotsUpload
        delete_screenshots
      elsif action == ScreenshotsDeletion
      else
        raise RuntimeError.new("Action #{action} is not implemented")
      end

    elsif video?
      if action == VideoUpload
        delete_video
      elsif action == VideoDeletion
      else
        raise RuntimeError.new("Action #{action} is not implemented")
      end

    else
      klass = Object.const_get(self.model.capitalize.to_sym)
      item = klass.find(self.item_id)
      self.prior = item[self.column]
    end
    self.status = is_rejected ? UserChangeStatus::Rejected : UserChangeStatus::Deleted

    self.save
  end

  # принятие правки
  def apply approver_id, taken
    self.approver_id = approver_id

    item = self.item

    # для скриншотов спец логика
    if screenshots?
      if action == ScreenshotsPosition
        apply_screenshots_positions
      elsif action == ScreenshotsUpload
        accept_screenshots
      elsif action == ScreenshotsDeletion
        delete_screenshots
      else
        raise RuntimeError.new("Action #{action} is not implemented")
      end

    elsif video?
      if action == VideoUpload
        accept_video
      elsif action == VideoDeletion
        delete_video
      else
        raise RuntimeError.new("Action #{action} is not implemented")
      end

    else
      self.prior = item[column]
      # send на случай переопределение сеттера
      item.send("#{column}=", sanitize(value))
    end

    item.source = source if item.respond_to? :source
    self.status = taken ? UserChangeStatus::Taken : UserChangeStatus::Accepted
    self.status = UserChangeStatus::Accepted if description? && self.prior.blank?
    save
    item.save
  end

  # применение позиций скриншотов
  def apply_screenshots_positions
    self.prior = current_screenshots.map(&:id).join(',')
    positioned_screenshots.each_with_index do |screenshot, index|
      screenshot.update_attribute(:position, index)
    end
  end

  # оказ применения позиций скриншотов
  def deny_screenshots_positions
    self.prior = current_screenshots.map(&:id).join(',')
  end

  # принятие скриншотов
  def accept_screenshots
    attached_screenshots.each(&:mark_accepted)
  end

  # удаление скриншотов
  def delete_screenshots
    attached_screenshots.each(&:mark_deleted)
  end

  # принятие видео
  def accept_video
    attached_video.confirm if attached_video.can_confirm?
  end

  # удаление видео
  def delete_video
    attached_video.del if attached_video.can_del?
  end

  # текущее значение изменяемой сущности
  def current_value
    if screenshots?
      if action == ScreenshotsPosition
        current_screenshots.map(&:id).join(',')
      else
        raise RuntimeError.new("Action #{action} is not supported yet")
      end
    else
      self.item.send(self.column)
    end
  end

  # текущие скриншоты изменяемой сущности
  def current_screenshots
    self.item.screenshots.where(id: self.value.split(','))
  end

  # при добавлении/удалении скриншота, можно обратиться к самому скриншоту
  def attached_screenshots
    Screenshot.where(id: self.value.split(','))
  end

  def attached_video
    Video.find(self.value)
  end

  # описание правки для уведомлений
  def name
    if screenshots?
      case action
        when ScreenshotsPosition
          'порядок кадров'

        when ScreenshotsUpload
          'загрузка кадров'

        when ScreenshotsDeletion
          'удаление кадров'

        when VideoUpload
          'загрузка видео'

        when VideoDeletion
          'удаление видео'

        else
          raise RuntimeError.new("Action #{action} is not supported yet")
      end
    else
      column
    end
  end

  # ключ для кеша
  def cache_key(moderation, current_user)
    "change-#{id}-#{moderation}-#{self[:locked]}-#{updated_at}_#{current_user && current_user.user_changes_moderator?}_#{current_user && current_user.admin?}"
  end

private
  # снятие лока после принятия правки
  def release_lock
    if description?
      UserChange.where(model: model, item_id: item_id, status: UserChangeStatus::Locked).destroy_all
    end
  end
end
