# frozen_string_literal: true

class Topic::Update
  method_object %i[topic! params! faye!]

  def call
    is_updated = update_topic

    if is_updated
      broadcast @topic if broadcast? @topic
    end

    is_updated
  end

private

  def update_topic
    @topic.class.wo_timestamp do
      @faye.update @topic, @params
    end
  end

  def broadcast? topic
    Topic::BroadcastPolicy.new(topic).required?
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_async topic.id
  end
end
