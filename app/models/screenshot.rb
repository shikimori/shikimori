# interpolate in paperclip
Paperclip.interpolates :access_token  do |attachment, style|
  attachment.instance.access_token
end

# скриншоты, имеющие status не отображаются. это или только загруженные, или
class Screenshot < ActiveRecord::Base
  Uploaded = 'uploaded'
  Deleted = 'deleted'

  belongs_to :anime

  validates_attachment_presence :image
  #validates_presence_of :anime # ну что за хрень с валидациями??
  validates_presence_of :url

  has_attached_file :image,
    styles: { preview: ['170x95#', :jpg] },
    url: "/images/screenshot/:style/:access_token.:extension"

  def access_token
    # для пары аниме по кривому адресу лежат
    if self.anime_id == 9969 || self.anime_id == 15417
      Digest::SHA1.hexdigest("918:#{self.url}")
    elsif self.anime_id == 12365
      Digest::SHA1.hexdigest("7674:#{self.url}")
    elsif self.anime_id == 3044
      Digest::SHA1.hexdigest("2747:#{self.url}")
    else
      Digest::SHA1.hexdigest("#{self.anime_id}:#{self.url}")
    end
  end

  def can_be_uploaded_by?(user)
    true
  end

  # направление скриншота на модерацию
  def suggest_acception(user)
    data = {
      model: Anime.name,
      item_id: self.anime_id,
      column: 'screenshots',
      action: UserChange::ScreenshotsUpload,
      user_id: user.id
    }
    change = UserChange.where(status: UserChangeStatus::Pending)
                       .where(data)
                       .first || UserChange.new(data)

    change.value = change.value.blank? ?
      self.id :
      change.value + ',' + self.id.to_s

    change.save!
  end

  # напреление скриншота на удаление
  def suggest_deletion(user)
    data = {
      model: Anime.name,
      item_id: self.anime_id,
      column: 'screenshots',
      action: UserChange::ScreenshotsDeletion,
      user_id: user.id
    }
    change = UserChange.where(status: UserChangeStatus::Pending)
                       .where(data)
                       .first || UserChange.new(data)

    change.value = change.value.blank? ?
      self.id :
      change.value + ',' + self.id.to_s

    change.save!
  end

  # пометка скриншота удалённым
  def mark_deleted
    update_attribute(:status, Deleted)
  end

  # пометка скриншота принятм
  def mark_accepted
    update_attribute(:status, nil)
  end
end
