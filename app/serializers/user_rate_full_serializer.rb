# TODO:
# change status (it is digit now) and status_name to status (string)
# rename UserRateFullSerializer to UserRateSerializer
class UserRateFullSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :text,
    :episodes, :chapters, :volumes, :text_html, :rewatches, :created_at, :updated_at

  has_one :user
  has_one :anime
  has_one :manga

  def episodes
    object.episodes if object.anime
  end

  def volumes
    object.volumes if object.manga
  end

  def chapters
    object.chapters if object.manga
  end

  def anime
    object.target if object.target.is_a? Anime
  end

  def manga
    object.target if object.target.is_a? Manga
  end
end
