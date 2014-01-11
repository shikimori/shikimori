class UserSerializer < ActiveModel::Serializer
  attributes :id, :nickname, :avatar, :image

  def avatar
    object.avatar_url 48
  end

  def image
    {
      x160: object.avatar_url(160),
      x148: object.avatar_url(148),
      x80: object.avatar_url(80),
      x64: object.avatar_url(64),
      x48: object.avatar_url(48),
      x32: object.avatar_url(32),
      x16: object.avatar_url(16),
    }
  end
end
