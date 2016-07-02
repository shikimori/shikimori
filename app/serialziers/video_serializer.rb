class VideoSerializer < ActiveModel::Serializer
  attributes :id, :url, :image_url, :player_url, :name, :kind, :hosting

  def player_url
    Url.new(object.player_url).with_http.to_s if object.player_url
  end

  def image_url
    Url.new(object.image_url).with_http.to_s if object.image_url
  end
end
