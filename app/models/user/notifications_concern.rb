# TODO: refactor this
module User::NotificationsConcern
  def unread
    @unread ||= Rails.cache.fetch [cache_key_with_version, :unread_count, :v2] do
      OpenStruct.new(
        count: unread_messages + unread_news + unread_notifications,
        messages: unread_messages,
        news: unread_news,
        notifications: unread_notifications
      )
    end
  end

private

  # number of unread private messages
  def unread_messages
    Message.where(to_id: id)
      .where(kind: MessageType::PRIVATE)
      .where(read: false)
      .where.not(from_id: ignored_user_ids, to_id: ignored_user_ids)
      .count
  end

  # number of unread notifications
  def unread_news
    Message.where(to_id: id)
      .where(kind: Messages::Query::NEWS_KINDS)
      .where(read: false)
      .where.not(from_id: ignored_user_ids, to_id: ignored_user_ids)
      .count
  end

  # number of unread notifications
  def unread_notifications
    Message.where(to_id: id)
      .where(kind: Messages::Query::NOTIFICATION_KINDS)
      .where(read: false)
      .where.not(from_id: ignored_user_ids, to_id: ignored_user_ids)
      .count
  end

  def ignored_user_ids
    @ignored_user_ids ||= ignores.map(&:target_id) + [0]
  end
end
