# frozen_string_literal: true

class Topics::Generate::Topic
  method_object %i[model! user! locale!]

  def call
    topic = build_topic

    if updated_at
      faye_service.create! topic
    else
      Topic.wo_timestamp { topic.save! }
    end

    topic
  end

private

  def build_topic
    if model.respond_to? :topics
      model.topics.find_by(find_by_attributes) ||
        model.topics.build(topic_attributes)
    else
      model.build_topic topic_attributes
    end
  end

  def topic_klass
    "Topics::EntryTopics::#{model.class.name}Topic".constantize
  end

  def topic_attributes
    {
      forum_id: forum_id,
      generated: true,
      user: user,
      type: topic_klass.name,
      locale: locale,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  def find_by_attributes
    topic_attributes.slice(:type, :locale)
  end

  def forum_id
    Topic::FORUM_IDS[model.class.name] || raise(ArgumentError, model.class.name)
  end

  def created_at
    model.created_at
  end

  def updated_at
    model.updated_at
  end

  def faye_service
    FayeService.new user, nil
  end
end
