# frozen_string_literal: true

class Topic::Update
  method_object %i[topic! params! faye!]

  def call
    is_updated = @topic.class.wo_timestamp do
      @faye.update @topic, @params
    end

    if is_updated
      broadcast @topic if broadcast? @topic
      @topic.update commented_at: Time.zone.now
    end

    is_updated
  end

private

  def broadcast? topic
    topic.saved_change_to_broadcast? && topic.broadcast && !topic.processed?
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_async topic
  end
end
