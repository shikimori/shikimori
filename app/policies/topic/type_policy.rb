class Topic::TypePolicy
  vattr_initialize :object

  def forum_topic?
    @object.instance_of?(Topic) || club_user_topic?
  end

  def news_topic?
    @object.instance_of? Topics::NewsTopic
  end

  def premoderated_news_topic?
    news_topic? && !@object.moderation_accepted?
  end

  def generated_news_topic?
    news_topic? && @object.generated?
  end

  def not_generated_news_topic?
    news_topic? && !@object.generated?
  end

  def critique_topic?
    @object.instance_of? Topics::EntryTopics::CritiqueTopic
  end

  def review_topic?
    @object.instance_of? Topics::EntryTopics::ReviewTopic
  end

  def cosplay_gallery_topic?
    @object.instance_of? Topics::EntryTopics::CosplayGalleryTopic
  end

  def contest_topic?
    @object.instance_of? Topics::EntryTopics::ContestTopic
  end

  def contest_status_topic?
    @object.instance_of? Topics::NewsTopics::ContestStatusTopic
  end

  def club_topic?
    @object.instance_of? Topics::EntryTopics::ClubTopic
  end

  def club_user_topic?
    @object.instance_of? Topics::ClubUserTopic
  end

  def club_page_topic?
    @object.instance_of? Topics::EntryTopics::ClubPageTopic
  end

  def any_club_topic?
    club_page_topic? || club_topic? || club_user_topic?
  end

  def collection_topic?
    @object.instance_of? Topics::EntryTopics::CollectionTopic
  end

  def article_topic?
    @object.instance_of? Topics::EntryTopics::ArticleTopic
  end

  def commentable_topic?
    !collection_topic? || @object.linked.published? || @object.linked.opened?
  end

  def votable_topic?
    critique_topic? ||
      cosplay_gallery_topic? ||
      review_topic? || (
        collection_topic? && (@object.linked.published? || @object.linked.opened?)
      )
  end
end
