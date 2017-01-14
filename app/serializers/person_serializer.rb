class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :image, :url

  def image
    {
      original: object.image.url(:original),
      preview: object.image.url(:preview),
      x96: object.image.url(:x96),
      x48: object.image.url(:x48)
    }
  end

  def url
    UrlGenerator.instance.person_path object
  end
end
