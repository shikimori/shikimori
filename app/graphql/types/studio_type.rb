class Types::StudioType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false

  field :image_url, String
  def image_url
    return unless object.image.exists?

    ImageUrlGenerator.instance.cdn_image_url object, :original
  end
end
