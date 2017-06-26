# frozen_string_literal: true

# NOTE: see AnimeHistoryAction for news topic names
class Topics::Generate::News::BaseTopic < Topics::Generate::SiteTopic
  attr_implement :action, :value, :created_at

private

  def build_topic
    model.news_topics.find_by(find_by_attributes) ||
      model.news_topics.build(topic_attributes)
  end

  def topic_klass
    Topics::NewsTopic
  end

  def topic_attributes
    super.merge(
      action: action,
      value: value
    )
  end

  def find_by_attributes
    super.merge topic_attributes.slice(:action, :value)
  end
end
