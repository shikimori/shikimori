class AddMentionEventToUserNotificationSettings < ActiveRecord::Migration[5.2]
  def up
    User.find_each do |user|
      user.notification_settings << Types::User::NotificationSettings[:mention_event]
      user.save! validate: false
    end
  end
end
