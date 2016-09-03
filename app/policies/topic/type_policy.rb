# frozen_string_literal: true

class Topic::TypePolicy
  pattr_initialize :topic

  def forum_topic?
    topic.class.name == Topic.name
  end

  def news_topic?
    topic.class.name == Topics::NewsTopic.name
  end

  def generated_news_topic?
    news_topic? && topic.generated?
  end

  def not_generated_news_topic?
    news_topic? && !topic.generated?
  end

  def review_topic?
    topic.class.name == Topics::EntryTopics::ReviewTopic.name
  end

  def cosplay_gallery_topic?
    topic.class.name == Topics::EntryTopics::CosplayGalleryTopic.name
  end

  def contest_topic?
    topic.class.name == Topics::EntryTopics::ContestTopic.name
  end
end
