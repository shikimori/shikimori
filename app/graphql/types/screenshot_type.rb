class Types::ScreenshotType < Types::BaseObject
  field :id, GraphQL::Types::BigInt

  %i[
    original
    x166
    x332
  ].each do |derivative|
    field :"#{derivative}_url", String
    define_method :"#{derivative}_url" do
      ImageUrlGenerator.instance.cdn_image_url object, derivative
    end
  end
end
