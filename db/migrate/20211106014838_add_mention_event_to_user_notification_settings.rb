class AddMentionEventToUserNotificationSettings < ActiveRecord::Migration[5.2]
  def up
    execute %q[
      UPDATE users SET notification_settings = notification_settings || ARRAY['mention_event']
    ]
  end

  def down
    execute %q[
      UPDATE users SET notification_settings = array_remove(notification_settings, 'mention_event')
    ]
  end
end
