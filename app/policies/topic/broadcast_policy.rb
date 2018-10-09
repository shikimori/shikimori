# frozen_string_literal: true

class Topic::BroadcastPolicy
  pattr_initialize :topic

  def required?
    return false if @topic.processed?

    broadcast? || generated_news?
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
end
