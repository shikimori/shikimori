# frozen_string_literal: true

class Topic::Create
  method_object %i[params! locale! faye!]

  # IS_NEWS_PREMODERATION = !Rails.env.production?

  def call
    topic = build_topic

    assign_forum topic if news? topic
    broadcast topic if @faye.create(topic) && broadcast?(topic)

    topic
  end

private

  def build_topic
    topic = Topic.new @params.merge(locale: @locale)
    topic.is_censored = topic.linked.try(:censored?) || false
    topic
  end

  def assign_forum topic
    topic.forum_id = premoderation?(topic) ?
      Forum::PREMODERATION_ID :
      Forum::NEWS_ID
  end

  def broadcast? topic
    Topic::BroadcastPolicy.new(topic).required?
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_in 10.seconds, topic.id
  end

  def news? topic
    topic.is_a? Topics::NewsTopic
  end

  def premoderation? topic
    # IS_NEWS_PREMODERATION &&
    !topic.user.trusted_newsmaker?
  end
end
