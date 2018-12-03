class OldMessagesCleaner
  include Sidekiq::Worker

  def perform
    Message
      .where(kind: [
        MessageType::EPISODE, MessageType::ANONS, MessageType::ONGOING,
        MessageType::RELEASED, MessageType::PROFILE_COMMENTED,
        MessageType::QUOTED_BY_USER, MessageType::SUBSCRIPTION_COMMENTED
      ])
      .where('created_at <= ?', 3.month.ago)
      .delete_all
  end
end
