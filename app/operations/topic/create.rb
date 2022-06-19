# frozen_string_literal: true

class Topic::Create
  method_object %i[params! locale! faye!]

  # IS_NEWS_PREMODERATION = !Rails.env.production?

  def call
    topic = build_topic

    premoderate topic if premoderation? topic
    broadcast topic if @faye.create(topic) && broadcast?(topic)

    topic
  end

private

  def build_topic
    Topic.new @params.merge(locale: @locale)
  end

  def broadcast? topic
    Topic::BroadcastPolicy.new(topic).required?
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_in 10.seconds, topic.id
  end

  def premoderation? topic
    # IS_NEWS_PREMODERATION &&
    topic.is_a?(Topics::NewsTopic) && !topic.user.trusted_newsmaker?
  end

  def premoderate topic
    topic.forum_id = Forum::PREMODERATION_ID
  end
end
