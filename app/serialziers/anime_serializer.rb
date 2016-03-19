# TODO: delete "ongoing?", "anons?" after 01.09.2015
class AnimeSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :image, :url, :kind, :ongoing?, :anons?,
    :status, :episodes, :episodes_aired

  def image
    {
      original: object.image.url(:original),
      preview: object.image.url(:preview),
      x96: object.image.url(:x96),
      x48: object.image.url(:x48)
    }
  end

  def url
    anime_path object
  end
end
