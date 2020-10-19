class UserSerializer < ActiveModel::Serializer
  attributes :id,
    :nickname,
    :avatar,
    :image,
    :last_online_at,
    :url

  def avatar
    ImageUrlGenerator.instance.url object, :x48
  end

  def image
    {
      x160: ImageUrlGenerator.instance.url(object, :x160),
      x148: ImageUrlGenerator.instance.url(object, :x148),
      x80: ImageUrlGenerator.instance.url(object, :x80),
      x64: ImageUrlGenerator.instance.url(object, :x64),
      x48: ImageUrlGenerator.instance.url(object, :x48),
      x32: ImageUrlGenerator.instance.url(object, :x32),
      x16: ImageUrlGenerator.instance.url(object, :x16)
    }
  end

  def last_online_at
    object[:last_online_at]
  end

  def url
    UrlGenerator.instance.profile_url(object)
  end
end
