class UserSerializer < ActiveModel::Serializer
  attributes :id,
    :nickname,
    :avatar,
    :image,
    :last_online_at,
    :url

  def avatar
    object.avatar_url(48, own_profile?)
  end

  def image
    {
      x160: object.avatar_url(160, own_profile?),
      x148: object.avatar_url(148, own_profile?),
      x80: object.avatar_url(80, own_profile?),
      x64: object.avatar_url(64, own_profile?),
      x48: object.avatar_url(48, own_profile?),
      x32: object.avatar_url(32, own_profile?),
      x16: object.avatar_url(16, own_profile?)
    }
  end

  def last_online_at
    object[:last_online_at]
  end

  def nickname
    object.nickname own_profile?
  end

  def url
    UrlGenerator.instance.profile_url(object)
  end

private

  def own_profile?
    scope.respond_to?(:user_signed_in?) &&
      scope.user_signed_in? &&
      scope.current_user.id == object.id
  end
end
