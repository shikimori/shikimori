class AnimeSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :image, :url, :kind, :ongoing?, :anons?, :episodes, :episodes_aired

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
    anime_path object
  end
end
