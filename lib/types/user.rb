module Types
  module User
    ROLES = %i[
      admin
      forum_moderator
      review_moderator
      collection_moderator
      version_moderator
      contest_moderator
      cosplay_moderator
      video_moderator
      video_super_moderator
      api_video_uploader
      trusted_video_uploader
      not_trusted_video_uploader
      trusted_video_changer
      trusted_version_changer
      not_trusted_version_changer
      trusted_ranobe_external_links_changer
      translator
      bot
      censored_avatar
      censored_profile
      retired_moderator
    ]
    Roles = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ROLES)
  end
end
