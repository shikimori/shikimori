# TODO: delete "ongoing?", "anons?" after 01.09.2015
class MangaSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :image, :url, :ongoing?, :anons?, :status, :volumes, :chapters

  def image
    {
      original: object.image.url(:original),
      preview: object.image.url(:preview),
      x96: object.image.url(:x96),
      x48: object.image.url(:x48)
    }
  end

  def url
    manga_path object
  end
end
