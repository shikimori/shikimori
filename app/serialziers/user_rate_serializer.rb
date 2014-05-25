class UserRateSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :status_name, :text, :episodes, :chapters, :volumes, :text_html, :rewatches

  has_one :user
  has_one :anime
  has_one :manga

  def episodes
    object.episodes if object.anime?
  end

  def volumes
    object.volumes if object.manga?
  end

  def chapters
    object.chapters if object.manga?
  end

  def anime
    object.target.kind_of?(Anime) ? object.target : nil
  end

  def manga
    object.target.kind_of?(Manga) ? object.target : nil
  end

  def status
    UserRate.status_id object.status
  end

  def status_name
    UserListParsers::XmlListParser.status_to_string(object.status, object.target.class, false)
  end
end
