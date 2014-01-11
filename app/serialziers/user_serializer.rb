class UserSerializer < ActiveModel::Serializer
  include UsersHelper
  attributes :id, :nickname, :avatar, :image

  def avatar
    gravatar_url object, 48
  end

  def image
    {
      x160: gravatar_url(object, 160),
      x148: gravatar_url(object, 148),
      x80: gravatar_url(object, 80),
      x64: gravatar_url(object, 64),
      x48: gravatar_url(object, 48),
      x32: gravatar_url(object, 32),
      x16: gravatar_url(object, 16)
    }
  end
end
