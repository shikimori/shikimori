class UserSerializer < ActiveModel::Serializer
  attributes :id,
    :nickname,
    :avatar,
    :image,
    :last_online_at,
    :url

  def avatar
    with_http object.avatar_url(48)
  end

  def image
    {
      x160: with_http(object.avatar_url(160)),
      x148: with_http(object.avatar_url(148)),
      x80: with_http(object.avatar_url(80)),
      x64: with_http(object.avatar_url(64)),
      x48: with_http(object.avatar_url(48)),
      x32: with_http(object.avatar_url(32)),
      x16: with_http(object.avatar_url(16))
    }
  end

  def last_online_at
    object[:last_online_at]
  end

  def url
    view_context.profile_url(object)
  end

private

  def with_http url
    Url.new(url).with_http.to_s
  end
end
