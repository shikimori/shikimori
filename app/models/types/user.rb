module Types
  module User
    VERSION_ROLES = %i[
      version_moderator
      version_names_moderator
      version_texts_moderator
      version_fansub_moderator
      version_videos_moderator
      version_images_moderator
      version_links_moderator
    ]

    ROLES_EXCLUDED_FROM_STATISTICS = %i[
      cheat_bot
      completed_announced_animes
      ignored_in_achievement_statistics
      mass_registration
      permaban
    ]

    ROLES = %i[
      super_moderator
      news_super_moderator
      forum_moderator
      retired_moderator
    ] + VERSION_ROLES + %i[
      trusted_version_changer
      trusted_episodes_changer
      trusted_newsmaker

      not_trusted_version_changer
      not_trusted_names_changer
      not_trusted_texts_changer
      not_trusted_fansub_changer
      not_trusted_videos_changer
      not_trusted_images_changer
      not_trusted_links_changer

      critique_moderator
      collection_moderator
      news_moderator
      article_moderator
      cosplay_moderator
      contest_moderator
      statistics_moderator
      genre_moderator

      video_super_moderator

      not_trusted_collections_author
      not_trusted_abuse_reporter

      censored_avatar
      censored_profile
      censored_nickname
    ] + ROLES_EXCLUDED_FROM_STATISTICS + %i[
      permaban

      ai_genres
      censored_genres

      bot
      admin
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

      mention_event
    ]
    NotificationSettings = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NOTIFICATION_SETTINGS)

    Sexes = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:male, :female)
  end
end
