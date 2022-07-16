# frozen_string_literal: true

class Topics::Generate::Topic
  method_object %i[model! user! locale! forum_id]

  def call
    topic = build_topic
    return topic if topic.persisted?

    topic.disable_antispam!

    if updated_at
      faye_service.create! topic
    else
      topic.class.wo_timestamp { topic.save! }
    end

    broadcast topic if broadcast? topic

    topic
  end

private

  def build_topic
    if @model.respond_to? :topics
      @model.topics.find_by(attributes_of_find_by) ||
        @model.topics.build(topic_attributes)
    else
      @model.build_topic topic_attributes
    end
  end

  def topic_klass
    "Topics::EntryTopics::#{@model.class.name}Topic".constantize
  end

  def topic_attributes
    {
      forum_id: forum_id,
      generated: true,
      user: @user,
      type: topic_klass.name,
      locale: @locale,
      is_censored: censored?,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  def attributes_of_find_by
    topic_attributes.slice(:type, :locale)
  end

  def broadcast? topic
    Topic::BroadcastPolicy.new(topic).required?
  end

  def broadcast topic
    Notifications::BroadcastTopic.perform_in 10.seconds, topic.id
  end

  def forum_id
    @forum_id ||
      Topic::FORUM_IDS[@model.class.name] ||
      raise(ArgumentError, @model.class.name)
  end

  def censored?
    @model.try(:censored?) || false
  end

  def created_at
    @model.created_at
  end

  def updated_at
    @model.updated_at
  end

  def faye_service
    FayeService.new @user, nil
  end
end
