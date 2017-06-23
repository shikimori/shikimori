class Topics::TopicViewFactory
  pattr_initialize :is_preview, :is_mini

  def find topic_id
    build Topic.find(topic_id)
  end

  # rubocop:disable MethodLength
  def build topic
    topic_type_policy = Topic::TypePolicy.new(topic)

    if topic_type_policy.review_topic?
      review_topic topic

    elsif topic_type_policy.contest_topic?
      contest_topic topic

    elsif topic_type_policy.contest_started_topic?
      contest_started_topic topic

    elsif topic_type_policy.contest_finished_topic?
      contest_finished_topic topic

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

    else
      common_topic topic
    end
  end
  # rubocop:enable MethodLength

private

  def review_topic topic
    Topics::ReviewView.new topic, is_preview, is_mini
  end

  def contest_topic topic
    Topics::ContestView.new topic, is_preview, is_mini
  end

  def contest_started_topic topic
    Topics::ContestStartedView.new topic, is_preview, is_mini
  end

  def contest_finished_topic topic
    Topics::ContestFinishedView.new topic, is_preview, is_mini
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

  def common_topic topic
    Topics::View.new topic, is_preview, is_mini
  end
end
