module Types
  module User
    ROLES = %i[
      forum_moderator
      retired_moderator
      version_moderator
      trusted_version_changer
      not_trusted_version_changer
      trusted_ranobe_external_links_changer
      review_moderator
      collection_moderator
      cosplay_moderator
      contest_moderator
      video_super_moderator
      video_moderator
      api_video_uploader
      trusted_video_uploader
      not_trusted_video_uploader
      trusted_video_changer
      censored_avatar
      censored_profile
      bot
      admin
    ]
    Roles = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ROLES)
  end
end
