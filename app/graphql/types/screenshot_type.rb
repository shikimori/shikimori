class Types::ScreenshotType < Types::BaseObject
  field :id, ID, null: false

  %i[
    original
    x166
    x332
  ].each do |derivative|
    field :"#{derivative}_url", String, null: false
    define_method :"#{derivative}_url" do
      ImageUrlGenerator.instance.cdn_image_url object, derivative
    end
  end
end
