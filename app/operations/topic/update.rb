# frozen_string_literal: true

class Topic::Update
  method_object %i[topic! params! faye!]

  def call
    is_updated = update_topic
    broadcast @topic if is_updated && broadcast?(@topic)
    is_updated
  end

private

  def update_topic
    @faye.update @topic, @params
  end

  def broadcast? topic
    Topic::BroadcastPolicy.new(topic).required?
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_in 10.seconds, topic.id
  end
end
