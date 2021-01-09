class Topic::TypePolicy
  pattr_initialize :topic

  def forum_topic?
    topic.instance_of?(Topic) || club_user_topic?
  end

  def news_topic?
    topic.instance_of? Topics::NewsTopic
  end

  def generated_news_topic?
    news_topic? && topic.generated?
  end

  def not_generated_news_topic?
    news_topic? && !topic.generated?
  end

  def review_topic?
    topic.instance_of? Topics::EntryTopics::ReviewTopic
  end

  def cosplay_gallery_topic?
    topic.instance_of? Topics::EntryTopics::CosplayGalleryTopic
  end

  def contest_topic?
    topic.instance_of? Topics::EntryTopics::ContestTopic
  end

  def contest_status_topic?
    topic.instance_of? Topics::NewsTopics::ContestStatusTopic
  end

  def club_topic?
    topic.instance_of? Topics::EntryTopics::ClubTopic
  end

  def club_user_topic?
    topic.instance_of? Topics::ClubUserTopic
  end

  def club_page_topic?
    topic.instance_of? Topics::EntryTopics::ClubPageTopic
  end

  def any_club_topic?
    club_page_topic? || club_topic? || club_user_topic?
  end

  def collection_topic?
    topic.instance_of? Topics::EntryTopics::CollectionTopic
  end

  def article_topic?
    topic.instance_of? Topics::EntryTopics::ArticleTopic
  end

  def votable_topic?
    review_topic? || cosplay_gallery_topic? || (
      collection_topic? && (topic.linked.published? || topic.linked.hidden?)
    )
  end
end
