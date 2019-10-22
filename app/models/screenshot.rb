# скриншоты, имеющие status не отображаются. это или только загруженные, или
class Screenshot < ApplicationRecord
  UPLOADED = 'uploaded'
  DELETED = 'deleted'

  belongs_to :anime, touch: true

  has_attached_file :image,
    styles: { x166: ['166x93#', :jpg], x332: ['332x186#', :jpg] },
    url: '/system/screenshots/:style/:access_token.:extension'

  # validates_presence_of :anime # ну что за хрень с валидациями??
  validates :image,
    attachment_presence: true,
    attachment_content_type: { content_type: /\Aimage/ }
  validates :url, :anime, presence: true

  def access_token
    # для пары аниме по кривому адресу лежат
    if anime_id == 9969 || anime_id == 15_417
      Digest::SHA1.hexdigest("918:#{url}")
    elsif anime_id == 12_365
      Digest::SHA1.hexdigest("7674:#{url}")
    elsif anime_id == 3044
      Digest::SHA1.hexdigest("2747:#{url}")
    else
      Digest::SHA1.hexdigest("#{anime_id}:#{url}")
    end
  end

  def mark_deleted
    update_attribute :status, DELETED
  end

  def mark_accepted
    update_attribute :status, nil
  end
end
