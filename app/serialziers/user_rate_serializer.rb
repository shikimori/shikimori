class UserRateSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :status_name, :episodes, :volumes, :chapters, :text, :text_html, :rewatches

  has_one :user
  has_one :anime
  has_one :manga

  def anime
    object.target.kind_of?(Anime) ? object.target : nil
  end

  def manga
    object.target.kind_of?(Manga) ? object.target : nil
  end

  def status_name
    UserRateStatus.get object.status
  end
end
