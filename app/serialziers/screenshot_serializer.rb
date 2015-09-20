class ScreenshotSerializer < ActiveModel::Serializer
  attributes :original, :preview

  def original
    object.image.url :original
  end

  def preview
    object.image.url :x332
  end
end
