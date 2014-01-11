class StudioSerializer < ActiveModel::Serializer
  attributes :id, :name, :filtered_name, :real?, :image

  def image
    object.image.url if object.image.exists?
  end
end
