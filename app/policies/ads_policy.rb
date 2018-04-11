class AdsPolicy
  pattr_initialize %i[
    user!
    ad_provider!
    is_ru_host!
    is_shikimori!
    is_disabled!
  ]

  # rubocop:disable CyclomaticComplexity, PerceivedComplexity
  def allowed?
    return false if @is_disabled
    return false unless @is_ru_host

    return false if yandex_direct?(@ad_provider) && Rails.env.development?
    return false if yandex_direct?(@ad_provider) && !@is_shikimori
    return false if admachina?(@ad_provider) && Rails.env.development?
    return false if admachina?(@ad_provider) && !@is_shikimori

    return true unless @user
    return true if istari?(@ad_provider) || special?(@ad_provider)
    return true if user&.admin?

    !contributor?(@user)
  end
  # rubocop:enable CyclomaticComplexity, PerceivedComplexity

private

  def yandex_direct? ad_provider
    ad_provider == Types::Ad::Provider[:yandex_direct]
  end

  def istari? ad_provider
    ad_provider == Types::Ad::Provider[:istari]
  end

  def special? ad_provider
    ad_provider == Types::Ad::Provider[:special]
  end

  def admachina? ad_provider
    ad_provider == Types::Ad::Provider[:admachina]
  end

  def show_ad_to? user
  end

  def contributor? user
    user.forum_moderator? || user.review_moderator? ||
      user.version_moderator? || user.video_moderator? ||
      user.trusted_version_changer? || user.trusted_video_uploader?
  end
end
