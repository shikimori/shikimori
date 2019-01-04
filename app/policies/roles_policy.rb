class RolesPolicy
  include Draper::ViewHelpers

  RESTRICTED_ROLES = %i[
    not_trusted_version_changer
    not_trusted_video_uploader
    not_trusted_abuse_reporter
    censored_avatar
    censored_profile
    cheat_bot
  ]

  static_facade :accessible?, :role

  def accessible?
    !RESTRICTED_ROLES.include?(@role.to_sym) ||
      h.can?(:"manage_#{@role}_role", User)
  end
end
