class Messages::CleanupOutdated
  include Sidekiq::Worker

  EXPIRE_INTERVAL = 1.month

  KINDS = MessagesQuery::NEWS_KINDS + MessagesQuery::NOTIFICATION_KINDS - [
    MessageType::FRIEND_REQUEST,
    MessageType::CLUB_REQUEST
  ]

  def perform
    Message
      .where(kind: KINDS)
      .where('created_at <= ?', EXPIRE_INTERVAL.ago)
      .delete_all
  end
end
