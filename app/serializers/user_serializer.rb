class UserSerializer < ActiveModel::Serializer
  attributes :id,
    :nickname,
    :avatar,
    :image,
    :last_online_at,
    :url

  def avatar
    object.avatar_url(48)
  end

  def image
    {
      x160: object.avatar_url(160),
      x148: object.avatar_url(148),
      x80: object.avatar_url(80),
      x64: object.avatar_url(64),
      x48: object.avatar_url(48),
      x32: object.avatar_url(32),
      x16: object.avatar_url(16)
    }
  end

  def last_online_at
    object[:last_online_at]
  end

  def url
    UrlGenerator.instance.profile_url(object)
  end
end
