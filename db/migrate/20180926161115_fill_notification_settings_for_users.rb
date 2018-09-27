class FillNotificationSettingsForUsers < ActiveRecord::Migration[5.2]
  ANONS_TV_NOTIFICATIONS         = 0x000001
  ANONS_MOVIE_NOTIFICATIONS      = 0x000002
  ANONS_OVA_NOTIFICATIONS        = 0x000004

  ONGOING_TV_NOTIFICATIONS       = 0x000010
  ONGOING_MOVIE_NOTIFICATIONS    = 0x000020
  ONGOING_OVA_NOTIFICATIONS      = 0x000040

  MY_ONGOING_TV_NOTIFICATIONS    = 0x000100
  MY_ONGOING_MOVIE_NOTIFICATIONS = 0x000200
  MY_ONGOING_OVA_NOTIFICATIONS   = 0x000400

  RELEASE_TV_NOTIFICATIONS       = 0x001000
  RELEASE_MOVIE_NOTIFICATIONS    = 0x002000
  RELEASE_OVA_NOTIFICATIONS      = 0x004000

  MY_RELEASE_TV_NOTIFICATIONS    = 0x010000
  MY_RELEASE_MOVIE_NOTIFICATIONS = 0x020000
  MY_RELEASE_OVA_NOTIFICATIONS   = 0x040000

  MY_EPISODE_TV_NOTIFICATIONS    = 0x100000
  MY_EPISODE_MOVIE_NOTIFICATIONS = 0x200000
  MY_EPISODE_OVA_NOTIFICATIONS   = 0x400000

  NOTIFICATIONS_TO_EMAIL_SIMPLE  = 0x000008
  NOTIFICATIONS_TO_EMAIL_GROUP   = 0x000080
  NOTIFICATIONS_TO_EMAIL_NONE    = 0x000800
  PRIVATE_MESSAGES_TO_EMAIL      = 0x080000
  NICKNAME_CHANGE_NOTIFICATIONS  = 0x800000

  def up
    return if Rails.env.production?

    # run in console on production
    User.find_each do |user|
      if (user.notifications & ANONS_TV_NOTIFICATIONS != 0) ||
          (user.notifications & ANONS_MOVIE_NOTIFICATIONS != 0) ||
          (user.notifications & ANONS_OVA_NOTIFICATIONS != 0)
        user.notification_settings << Types::User::NotificationSettings[:any_anons]
      end

      if (user.notifications & ONGOING_TV_NOTIFICATIONS != 0) ||
          (user.notifications & ONGOING_MOVIE_NOTIFICATIONS != 0) ||
          (user.notifications & ONGOING_OVA_NOTIFICATIONS != 0)
        user.notification_settings << Types::User::NotificationSettings[:any_ongoing]
      end

      if (user.notifications & RELEASE_TV_NOTIFICATIONS != 0) ||
          (user.notifications & RELEASE_MOVIE_NOTIFICATIONS != 0) ||
          (user.notifications & RELEASE_OVA_NOTIFICATIONS != 0)
        user.notification_settings << Types::User::NotificationSettings[:any_released]
      end

      if (user.notifications & MY_ONGOING_TV_NOTIFICATIONS != 0) ||
          (user.notifications & MY_ONGOING_MOVIE_NOTIFICATIONS != 0) ||
          (user.notifications & MY_ONGOING_OVA_NOTIFICATIONS != 0)
        user.notification_settings << Types::User::NotificationSettings[:my_ongoing]
      end

      if (user.notifications & MY_RELEASE_TV_NOTIFICATIONS != 0) ||
          (user.notifications & MY_RELEASE_MOVIE_NOTIFICATIONS != 0) ||
          (user.notifications & MY_RELEASE_OVA_NOTIFICATIONS != 0)
        user.notification_settings << Types::User::NotificationSettings[:my_released]
      end

      if (user.notifications & MY_EPISODE_TV_NOTIFICATIONS != 0) ||
          (user.notifications & MY_EPISODE_MOVIE_NOTIFICATIONS != 0) ||
          (user.notifications & MY_EPISODE_OVA_NOTIFICATIONS != 0)
        user.notification_settings << Types::User::NotificationSettings[:my_episode]
      end

      if user.notifications & PRIVATE_MESSAGES_TO_EMAIL != 0
        user.notification_settings << Types::User::NotificationSettings[:private_message_email]
      end

      if user.notifications & NICKNAME_CHANGE_NOTIFICATIONS != 0
        user.notification_settings << Types::User::NotificationSettings[:friend_nickname_change]
      end

      user.save! validate: false
      puts user.id
    end
  end
end
