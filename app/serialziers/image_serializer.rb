class ImageSerializer < ActiveModel::Serializer
  attributes :id, :original, :main, :preview

  def original
    object.image.url :original
  end

  def main
    object.image.url :main
  end

  def preview
    object.image.url :preview
  end
end
