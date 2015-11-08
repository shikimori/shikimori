class EmailNotifier
  include Singleton

  ONLINE_USER_MESSAGE_DELAY = 10.minutes
  OFFLINE_USER_MESSAGE_DELAY = 1.second

  def private_message message
    return if notifications_disabled?(message.to)

    ShikiMailer
      .perform_in(delay_interval(message.to))
      .private_message_email(message)
  end

private
  def notifications_disabled? user
    user.notifications & User::PRIVATE_MESSAGES_TO_EMAIL == 0
  end

  def delay_interval user
    offline?(user) ? OFFLINE_USER_MESSAGE_DELAY : ONLINE_USER_MESSAGE_DELAY
  end

  def offline? user
    Time.zone.now - User::LAST_ONLINE_CACHE_INTERVAL > (user[:last_online_at] || user.created_at)
  end
end
