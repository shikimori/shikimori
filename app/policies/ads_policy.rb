class AdsPolicy
  pattr_initialize %i[is_ru_host is_shikimori ad_provider user_id]

  MODERATOR_IDS = User::MODERATORS + User::REVIEWS_MODERATORS +
    User::VERSIONS_MODERATORS + User::VIDEO_MODERATORS +
    User::TRUSTED_VERSION_CHANGERS + User::TRUSTED_VIDEO_UPLOADERS
  ADMIN_IDS = User::ADMINS

  FORBIDDEN_USER_IDS = MODERATOR_IDS.uniq - User::ADMINS

  def allowed?
    return false if yandex_direct? && Rails.env.development?

    @is_ru_host && allowed_user? && (@is_shikimori || !yandex_direct?)
  end

private

  def yandex_direct?
    @ad_provider == Types::Ad::Provider[:yandex_direct]
  end

  def allowed_user?
    !FORBIDDEN_USER_IDS.include?(@user_id)
  end
end
