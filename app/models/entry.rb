class Entry < ActiveRecord::Base
  include Commentable
  include Viewable

  NEWS_WALL = /[\r\n]*\[wall[\s\S]+\[\/wall\]\Z/
  WALL_ENTRY = /
    \[poster (?:=(?<id>\d+))\]
  /mix

  belongs_to :forum
  belongs_to :linked, polymorphic: true
  belongs_to :user

  validates :forum, presence: true unless Rails.env.test?

  has_many :messages,
    -> { where "linked_type = '#{self.class.name}' or linked_type = '#{Entry.name}'" },
    foreign_key: :linked_id,
    dependent: :delete_all
  has_many :topic_ignores, foreign_key: :topic_id, dependent: :destroy

  before_save :validates_linked

  # TODO: refactor into module
  # before_update :unclaim_images
  # before_destroy :destroy_images
  # after_save :claim_images

  # видимые топики
  scope :wo_empty_generated, -> {
    where '(comments_count > 0 and generated = true) or generated = false'
  }
  # топики без топиков о выходе эпизодов
  scope :wo_episodes, -> {
    where 'action is null or action != ?', AnimeHistoryAction::Episode
  }

  def to_param
    "%d-%s" % [id, permalink]
  end

  def cache_key
    "#{super}-#{Digest::MD5.hexdigest(body || '')}"
  end

  # базовый класс для комментариев
  def base_class
    Entry
  end

  # прочтен ли топик?
  def viewed?
    generated? ? true : super
  end

  # колбек, срабатываемый при добавлении коммента
  def comment_added comment
    self.updated_at = Time.zone.now
    # because automatically generated topics have no created_at
    self.created_at ||= self.updated_at if self.comments_count == 1 && !generated_news?
    save
  end

  # колбек, срабатываемый при удалении коммента
  def comment_deleted comment
    self.class.record_timestamps = false
    update(
      updated_at: self.comments.count > 0 ? self.comments.first.created_at : self.created_at,
      comments_count: self.comments.count
    )
    self.class.record_timestamps = true
  end

  def title= value
    super value
    self.permalink = self.to_s.permalinked if value.present?
    value
  end

  def to_s
    self.title
  end

  # оффтопик ли это? для совместимости с интерфейсом отображения комментариев
  def offtopic?
    false
  end

  # сгенерированный ли топик
  def topic?
    self.class == Topic
  end

  # сгенерированный ли топик
  def generated?
    generated
  end

  # новостной ли это топиик?
  def news?
    !!(self.class.name =~ /News/)
  end

  # топик ли это сгенерированной новости?
  def generated_news?
    news? && generated?
  end

  # топик ли это обзора?
  def review?
    self.class == ReviewComment
  end

  # топик ли это косплей?
  def cosplay?
    self.class == CosplayComment
  end

  # по опросу ли данный топик
  def contest?
    self.class == ContestComment
  end

  # def user_image_ids value=self.value
    # (value || '').split(',').map(&:to_i).select { |v| v > 0 }
  # end

  # def user_image_ids= ids
    # self.value = (ids || []).join(',')
  # end

  # # картинки, загруженные пользователями в топик
  # def attached_images
    # ids = user_image_ids

    # if ids.any?
      # UserImage
        # .where(id: ids)
        # .sort_by {|v| ids.index v.id }
    # else
      # []
    # end
  # end

  # оригинальный текст без сгенерированных автоматом тегов
  def original_text
    if generated?
      text
    else
      (text || '').sub(NEWS_WALL, '')
    end
  end

  # сгенерированные автоматом теги
  def appended_text
    if generated?
      ''
    else
      (text || '')[NEWS_WALL] || ''
    end
  end

  # TODO: should ALWAYS be called after text assign
  def wall_ids= ids
    # TODO: do not user "value" as user_images storage field
    self.value = ids.join(',')

    ids = ids.map(&:to_i)
    images = UserImage.where(id: ids).sort_by { |v| ids.index v.id }

    bb_images = images.map do |image|
      "[url=#{ImageUrlGenerator.instance.url image, :original}][poster=#{image.id}][/url]"
    end

    if bb_images.any?
      self.text = "#{original_text}\n[wall]#{bb_images.join ''}[/wall]"
    else
      self.text = original_text
    end
  end

  def wall_images
    ids = appended_text.scan(WALL_ENTRY).map { |v| v[0].to_i }
    UserImage.where(id: ids).sort_by { |v| ids.index v.id }
  end

private

  # проверка, что linked при его наличии нужного типа
  def validates_linked
    return unless self[:linked_type].present? && self[:linked_type] !~ /^(Anime|Manga|Character|Person|Club|Review|Contest|CosplayGallery)$/
    errors[:linked_type] = 'Forbidden Linked Type'
    return false
  end

  # пометка картинок на принадлежность текущему топику
  # def claim_images
    # UserImage
      # .where(id: user_image_ids, linked_id: nil, linked_type: Entry.name)
      # .update_all(linked_id: id, linked_type: Entry.name)
  # end

  # # удаление более неиспользуемых картинок
  # def unclaim_images
    # if changes['value'].present? && !generated?
      # unused_ids = user_image_ids(changes['value'][0]) - user_image_ids

      # UserImage
        # .where(id: unused_ids, linked_id: id, linked_type: Entry.name)
        # .destroy_all
    # end
  # end

  # # полное удаление всех картинок
  # def destroy_images
    # attached_images
      # .select { |v| v.linked_id == id && v.linked_type == Entry.name }
      # .each(&:destroy)
  # end
end
