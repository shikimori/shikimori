class OldMessagesCleaner
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    Message
      .where(kind: [MessageType::Episode, MessageType::Anons, MessageType::Ongoing, MessageType::Release, MessageType::ProfileCommented, MessageType::QuotedByUser, MessageType::SubscriptionCommented])
      .where('created_at >= ?', 3.month.ago)
      .delete_all
  end
end
