# frozen_string_literal: true

class Topics::Generate::News::BaseTopic < Topics::Generate::SiteTopic
  def call
    topic_klass.wo_timestamp do
      topic = build_topic
      topic.save!
      topic
    end
  end

  attr_implement :processed, :action, :value, :created_at

private

  def topic_klass
    Topics::NewsTopic
  end

  def topic_attributes
    super.merge(
      processed: processed,
      action: action,
      value: value
    )
  end
end
