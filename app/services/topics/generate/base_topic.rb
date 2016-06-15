# frozen_string_literal: true

class Topics::Generate::BaseTopic < ServiceObjectBase
  pattr_initialize :model, :user, :locale

  attr_implement :call

private

  def build_topic
    model.topics.find_by(find_by_attributes) ||
      model.topics.build(topic_attributes)
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
    Topic::FORUM_IDS[model.class.name] ||
      fail(ArgumentError, model.class.name)
  end

  def created_at
    model.created_at
  end

  def updated_at
    model.updated_at
  end
end
