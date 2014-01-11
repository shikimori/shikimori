class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :image, :url

  def image
    {
      original: object.image.url(:original),
      preview: object.image.url(:preview),
      x64: object.image.url(:x64)
    }
  end

  def url
    person_path object
  end
end
