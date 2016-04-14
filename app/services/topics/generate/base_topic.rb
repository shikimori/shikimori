# frozen_string_literal: true

class Topics::Generate::BaseTopic < ServiceObjectBase
  pattr_initialize :model, :user

  attr_implement :call

private

  def faye_service
    FayeService.new user, ''
  end

  def build_topic
    model.build_topic topic_attributes
  end

  def topic_klass
    "Topics::EntryTopics::#{model.class.name}Topic".constantize
  end

  def topic_attributes
    {
      forum_id: forum_id,
      generated: true,
      #linked: model,
      user: user,
      type: topic_klass.name,
      created_at: model.created_at,
      updated_at: model.updated_at
    }
  end

  def forum_id
    Topic::FORUM_IDS[model.class.name]
  end
end
