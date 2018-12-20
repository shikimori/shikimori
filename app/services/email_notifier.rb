class EmailNotifier
  include Singleton

  DAILY_USER_EMAILS_LIMIT = 13

  ONLINE_USER_MESSAGE_DELAY = 10.minutes
  OFFLINE_USER_MESSAGE_DELAY = 5.seconds

  def private_message message
    return if notifications_disabled? message.to
    return if too_many_messages? message.from

    ShikiMailer
      .delay_for(delay_interval(message.to))
      .private_message_email(message.id)
  end

private

  def notifications_disabled? user
    !user.notification_settings_private_message_email?
  end

  def too_many_messages? user
    return false if user.version_moderator? || user.forum_moderator? || user.admin?

    user_daily_private_messages(user).count >= DAILY_USER_EMAILS_LIMIT
  end

  def delay_interval user
    offline?(user) ? OFFLINE_USER_MESSAGE_DELAY : ONLINE_USER_MESSAGE_DELAY
  end

  def offline? user
    Time.zone.now - User::LAST_ONLINE_CACHE_INTERVAL > (user.last_online_at || user.created_at)
  end

  def user_daily_private_messages user
    user.messages
      .where(kind: MessageType::PRIVATE)
      .where('created_at > ?', 1.day.ago)
  end
end
