# frozen_string_literal: true

class Topic::Create
  method_object %i[params! faye!]

  def call
    topic = build_topic

    assign_forum topic if news? topic
    broadcast topic if @faye.create(topic) && broadcast?(topic)

    topic
  end

private

  def build_topic
    topic = Topic.new @params
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
    !Ability.new(topic.user).can? :accept, topic
  end
end
