class AnimeSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :image, :url, :kind, :ongoing?, :anons?, :episodes, :episodes_aired

  def image
    {
      original: object.image.url(:original),
      preview: object.image.url(:preview),
      x96: object.image.url(:x96),
      x64: object.image.url(:x64)
    }
  end

  def url
    anime_path object
  end
end
