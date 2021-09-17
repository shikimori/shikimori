module Types
  module User
    ROLES = %i[
      super_moderator
      news_super_moderator
      forum_moderator
      retired_moderator

      version_names_moderator
      version_texts_moderator
      version_moderator
      version_fansub_moderator

      trusted_version_changer

      not_trusted_version_changer
      not_trusted_names_changer
      not_trusted_texts_changer
      not_trusted_fansub_changer

      review_moderator
      collection_moderator
      news_moderator
      article_moderator
      cosplay_moderator
      contest_moderator
      statistics_moderator

      video_super_moderator

      not_trusted_abuse_reporter
      censored_avatar
      censored_profile
      cheat_bot
      completed_announced_animes
      ignored_in_achievement_statistics

      bot
      admin
    ]
    ROLES_EXCLUDED_FROM_STATISTICS = %i[
      cheat_bot
      completed_announced_animes
      ignored_in_achievement_statistics
    ]

    Roles = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ROLES)

    NOTIFICATION_SETTINGS = %i[
      any_anons
      any_ongoing
      any_released

      my_ongoing
      my_released
      my_episode

      private_message_email
      friend_nickname_change
      contest_event
    ]
    NotificationSettings = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NOTIFICATION_SETTINGS)
  end
end
