# TODO:
# change status (it is digit now) and status_name to status (string)
# rename UserRateFullSerializer to UserRateSerializer
# get rid of Api::V2::UserRatesController
class UserRateFullSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :text,
    :episodes, :chapters, :volumes, :text_html, :rewatches

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
    object.target.kind_of?(Anime) ? object.target : nil
  end

  def manga
    object.target.kind_of?(Manga) ? object.target : nil
  end
end
