class AddMentionEventToUserNotificationSettings < ActiveRecord::Migration[5.2]
  def up
    sql = "UPDATE users SET notification_settings = notification_settings || ARRAY['mention_event'];"
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    sql = "UPDATE users SET notification_settings = array_remove(notification_settings, 'mention_event');"
    ActiveRecord::Base.connection.execute(sql)
  end
end
