# frozen_string_literal: true

# NOTE: see AnimeHistoryAction for news topic names
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

  def build_topic
    model.news.find_by(find_by_attributes) ||
      model.news.build(topic_attributes)
  end

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

  def find_by_attributes
    topic_attributes.slice(:action, :value, :locale)
  end
end
