# frozen_string_literal: true

class Topic::BroadcastPolicy
  pattr_initialize :topic

  EPISODE_EXPIRATION_INTERVAL = 1.week
  RELEASED_EXPIRATION_INTERVAL = 1.month

  def required?
    return false if @topic.processed?

    broadcast? || (generated_news? && !expired_news?)
  end

private

  def broadcast?
    @topic.broadcast? &&
      @topic.saved_change_to_broadcast?
  end

  def generated_news?
    @topic.generated? &&
      @topic.saved_change_to_generated? &&
      @topic.is_a?(Topics::NewsTopic)
  end

  def expired_news?
    (
      @topic.action == Types::Topic::NewsTopic::Action[:episode] &&
      @topic.created_at < EPISODE_EXPIRATION_INTERVAL.ago
    ) || (
      @topic.action == Types::Topic::NewsTopic::Action[:released] &&
      @topic.created_at < RELEASED_EXPIRATION_INTERVAL.ago
    )
  end
end
