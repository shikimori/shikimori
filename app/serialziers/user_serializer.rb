class UserSerializer < ActiveModel::Serializer
  attributes :id, :nickname, :avatar, :image, :last_online_at

  def avatar
    object.avatar_url(48).with_http
  end

  def image
    {
      x160: object.avatar_url(160).with_http,
      x148: object.avatar_url(148).with_http,
      x80: object.avatar_url(80).with_http,
      x64: object.avatar_url(64).with_http,
      x48: object.avatar_url(48).with_http,
      x32: object.avatar_url(32).with_http,
      x16: object.avatar_url(16).with_http
    }
  end

  def last_online_at
    object[:last_online_at]
  end
end
