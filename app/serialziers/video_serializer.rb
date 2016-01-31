class VideoSerializer < ActiveModel::Serializer
  attributes :id, :url, :image_url, :player_url, :name, :kind, :hosting

  def image_url
    object.image_url
  end
end
