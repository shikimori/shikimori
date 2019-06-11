class AdsPolicy
  pattr_initialize %i[
    user!
    ad_provider!
    is_ru_host!
    is_disabled!
  ]

  def allowed?
    return false if @is_disabled
    return false unless @is_ru_host

    return true unless @user
    return true if user.admin?
    return true if special? @ad_provider

    !contributor?(@user)
  end

private

  def special? ad_provider
    ad_provider == Types::Ad::Provider[:special]
  end

  def contributor? user # rubocop:disable all
    user.forum_moderator? || user.review_moderator? ||
      user.version_moderator? || user.video_moderator? ||
      user.trusted_version_changer? || user.trusted_video_uploader? ||
       user.retired_moderator?
  end
end
