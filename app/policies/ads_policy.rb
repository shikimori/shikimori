class AdsPolicy
  pattr_initialize %i[
    user!
    ad_provider!
    is_ru_host!
    is_shikimori!
  ]

  # rubocop:disable CyclomaticComplexity, PerceivedComplexity
  def allowed?
    return false unless @is_ru_host
    return false if yandex_direct?(@ad_provider) && Rails.env.development?
    return false if yandex_direct?(@ad_provider) && !@is_shikimori
    return true unless @user
    return true if istari?(@ad_provider) || vgtrk?(@ad_provider)
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

  def vgtrk? ad_provider
    ad_provider == Types::Ad::Provider[:vgtrk]
  end

  def show_ad_to? user
  end

  def contributor? user
    user.forum_moderator? || user.review_moderator? ||
      user.version_moderator? || user.video_moderator? ||
      user.trusted_version_changer? || user.trusted_video_uploader?
  end
end
