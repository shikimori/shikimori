class RolesPolicy
  include Draper::ViewHelpers

  RESTRICTED_ROLES = %i[
    not_trusted_version_changer
    not_trusted_names_changer
    not_trusted_texts_changer
    not_trusted_fansub_changer
    not_trusted_videos_changer
    not_trusted_images_changer
    not_trusted_links_changer

    not_trusted_collections_author
    not_trusted_abuse_reporter

    censored_avatar
    censored_profile
    censored_nickname

    ai_genres
    censored_genres
  ] + ::Types::User::ROLES_EXCLUDED_FROM_STATISTICS

  static_facade :accessible?, :role

  def accessible?
    RESTRICTED_ROLES.exclude?(@role.to_sym) ||
      h.current_user&.staff? ||
      h.can?(:"manage_#{@role}_role", User)
  end
end
