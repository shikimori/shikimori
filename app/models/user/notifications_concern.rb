# TODO: refactor this
module User::NotificationsConcern
  def unread_count
    @unread_count ||= Rails.cache.fetch [cache_key_with_version, :unread_count] do
      unread_messages + unread_news + unread_notifications
    end
  end

  # number of unread private messages
  def unread_messages
    ignored_ids = ignores.map(&:target_id) << 0

    @unread_messages ||= Message.where(to_id: id)
      .where(kind: MessageType::PRIVATE)
      .where(read: false)
      .where.not(from_id: ignored_ids, to_id: ignored_ids)
      .count
  end

  # number of unread notifications
  def unread_news
    ignored_ids = ignores.map(&:target_id) + [0]

    @unread_news ||= Message.where(to_id: id)
      .where(kind: MessagesQuery::NEWS_KINDS)
      .where(read: false)
      .where.not(from_id: ignored_ids, to_id: ignored_ids)
      .count
  end

  # number of unread notifications
  def unread_notifications
    ignored_ids = ignores.map(&:target_id) + [0]

    @unread_notifications ||= Message.where(to_id: id)
      .where(kind: MessagesQuery::NOTIFICATION_KINDS)
      .where(read: false)
      .where.not(from_id: ignored_ids, to_id: ignored_ids)
      .count
  end
end
