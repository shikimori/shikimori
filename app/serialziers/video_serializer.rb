class VideoSerializer < ActiveModel::Serializer
  attributes :id, :url, :image_url, :player_url, :name, :kind, :hosting

  def player_url
    object.player_url.with_http
  end

  def image_url
    object.image_url.with_http
  end
end
