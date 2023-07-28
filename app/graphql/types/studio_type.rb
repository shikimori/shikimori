class Types::StudioType < Types::BaseObject
  field :id, ID
  field :name, String

  field :image_url, String
  def image_url
    return unless object.image.exists?

    ImageUrlGenerator.instance.cdn_image_url object, :original
  end
end