# frozen_string_literal: true

class Topic::Create
  method_object %i[faye! params! locale!]

  def call
    topic = Topic.new @params.merge(locale: @locale)

    if @faye.create topic
      broadcast topic if broadcast? topic
    end

    topic
  end

private

  def broadcast? topic
    topic.broadcast? ||
      (topic.is_a?(Topics::NewsTopic) && topic.generated?)
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_async topic
  end
end
