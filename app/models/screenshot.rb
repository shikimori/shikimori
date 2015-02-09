# скриншоты, имеющие status не отображаются. это или только загруженные, или
class Screenshot < ActiveRecord::Base
  Uploaded = 'uploaded'
  Deleted = 'deleted'

  belongs_to :anime

  has_attached_file :image,
    styles: { x166: ['166x93#', :jpg], x332: ['332x186#', :jpg] },
    url: "/images/screenshot/:style/:access_token.:extension"

  #validates_presence_of :anime # ну что за хрень с валидациями??
  validates :image, attachment_presence: true, attachment_content_type: { content_type: /\Aimage/ }
  validates :url, presence: true

  def access_token
    # для пары аниме по кривому адресу лежат
    if anime_id == 9969 || anime_id == 15417
      Digest::SHA1.hexdigest("918:#{url}")
    elsif anime_id == 12365
      Digest::SHA1.hexdigest("7674:#{url}")
    elsif anime_id == 3044
      Digest::SHA1.hexdigest("2747:#{url}")
    else
      Digest::SHA1.hexdigest("#{anime_id}:#{url}")
    end
  end

  def can_be_uploaded_by? user
    true
  end

  # направление скриншота на модерацию
  def suggest_acception user
    data = {
      model: Anime.name,
      item_id: anime_id,
      column: 'screenshots',
      action: UserChange::ScreenshotsUpload,
      user_id: user.id
    }
    change = UserChange
      .where(status: UserChangeStatus::Pending)
      .where(data)
      .first || UserChange.new(data)

    change.value = change.value.blank? ? id : "#{change.value},#{id}"
    change.save!
  end

  # напреление скриншота на удаление
  def suggest_deletion user
    data = {
      model: Anime.name,
      item_id: self.anime_id,
      column: 'screenshots',
      action: UserChange::ScreenshotsDeletion,
      user_id: user.id
    }
    change = UserChange
      .where(status: UserChangeStatus::Pending)
      .where(data)
      .first || UserChange.new(data)

    change.value = change.value.blank? ? id : "#{change.value},#{id}"
    change.save!
  end

  # пометка скриншота удалённым
  def mark_deleted
    update_attribute :status, Deleted
  end

  # пометка скриншота принятм
  def mark_accepted
    update_attribute :status, nil
  end
end
