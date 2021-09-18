class Topics::TopicViewFactory
  pattr_initialize :is_preview, :is_mini

  def find topic_id
    build Topic.find(topic_id)
  end

  def find_by params
    topic = Topic.find_by params
    build topic if topic
  end

  def build topic # rubocop:disable all
    topic_type_policy = Topic::TypePolicy.new(topic)

    if topic_type_policy.critique_topic?
      critique_topic topic

    elsif topic_type_policy.contest_topic?
      contest_topic topic

    elsif topic_type_policy.contest_status_topic?
      contest_status_topic topic

    elsif topic_type_policy.cosplay_gallery_topic?
      cosplay_topic topic

    elsif topic_type_policy.generated_news_topic?
      generated_news_topic topic

    elsif topic_type_policy.club_page_topic?
      club_page_topic topic

    elsif topic_type_policy.news_topic?
      news_topic topic

    elsif topic_type_policy.collection_topic?
      collection_topic topic

    elsif topic_type_policy.article_topic?
      article_topic topic

    else
      common_topic topic
    end
  end

private

  def critique_topic topic
    Topics::CritiqueView.new topic, is_preview, is_mini
  end

  def contest_topic topic
    Topics::ContestView.new topic, is_preview, is_mini
  end

  def contest_status_topic topic
    Topics::ContestStatusView.new topic, is_preview, is_mini
  end

  def cosplay_topic topic
    Topics::CosplayView.new topic, is_preview, is_mini
  end

  def generated_news_topic topic
    Topics::GeneratedNewsView.new topic, is_preview, is_mini
  end

  def news_topic topic
    Topics::NewsView.new topic, is_preview, is_mini
  end

  def club_page_topic topic
    Topics::ClubPageView.new topic, is_preview, is_mini
  end

  def collection_topic topic
    Topics::CollectionView.new topic, is_preview, is_mini
  end

  def article_topic topic
    Topics::ArticleView.new topic, is_preview, is_mini
  end

  def common_topic topic
    Topics::View.new topic, is_preview, is_mini
  end
end
