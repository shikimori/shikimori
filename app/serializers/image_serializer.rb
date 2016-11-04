class ImageSerializer < ActiveModel::Serializer
  attributes :id, :original_url, :main_url, :preview_url
  # NOTE: DEPRECATED. REMOFE AFTER 2017-06-01
  attributes :original, :main, :preview

  def original_url
    ImageUrlGenerator.instance.url object, :original
  end

  def main_url
    ImageUrlGenerator.instance.url object, :main
  end

  def preview_url
    ImageUrlGenerator.instance.url object, :preview
  end

  # NOTE: DEPRECATED. REMOFE AFTER 2017-06-01
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
