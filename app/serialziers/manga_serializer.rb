class MangaSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :image, :url, :ongoing?, :anons?, :volumes, :chapters

  def image
    {
      original: object.image.url(:original),
      preview: object.image.url(:preview),
      x96: object.image.url(:x96),
      x64: object.image.url(:x64), # deprecated. удалить после 01.06.2015
      x48: object.image.url(:x48)
    }
  end

  def url
    manga_path object
  end
end
