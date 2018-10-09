# frozen_string_literal: true

class Topic::Create
  method_object %i[faye! params! locale!]

  def call
    topic = create_topic

    if @faye.create topic
      broadcast topic if broadcast? topic
    end

    topic
  end

private

  def create_topic
    Topic.new @params.merge(locale: @locale)
  end

  def broadcast? topic
    Topic::BroadcastPolicy.new(topic).required?
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_async topic
  end
end
