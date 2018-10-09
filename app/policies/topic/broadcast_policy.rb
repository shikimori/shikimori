# frozen_string_literal: true

class Topic::BroadcastPolicy
  pattr_initialize :topic

  def required?
    return false if @topic.processed?

    (@topic.broadcast? && @topic.saved_change_to_broadcast?) ||
      (@topic.saved_change_to_generated? && @topic.is_a?(Topics::NewsTopic))
  end
end
