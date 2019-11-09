# frozen_string_literal: true

class Topic::TypePolicy
  pattr_initialize :topic

  def forum_topic?
    topic.class.name == Topic.name || club_user_topic?
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

  def contest_status_topic?
    topic.class.name == Topics::NewsTopics::ContestStatusTopic.name
  end

  def club_topic?
    topic.class.name == Topics::EntryTopics::ClubTopic.name
  end

  def club_user_topic?
    topic.class.name == Topics::ClubUserTopic.name
  end

  def club_page_topic?
    topic.class.name == Topics::EntryTopics::ClubPageTopic.name
  end

  def any_club_topic?
    club_page_topic? || club_topic? || club_user_topic?
  end

  def collection_topic?
    topic.class.name == Topics::EntryTopics::CollectionTopic.name
  end

  def article_topic?
    topic.class.name == Topics::EntryTopics::ArticleTopic.name
  end
end
