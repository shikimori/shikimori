class Topics::TopicViewFactory
  pattr_initialize :is_preview, :is_mini

  def find topic_id
    build Topic.find(topic_id)
  end

  # rubocop:disable MethodLength
  def build topic
    if topic.review_topic?
      review_topic topic

    elsif topic.contest_topic?
      contest_topic topic

    elsif topic.cosplay_gallery_topic?
      cosplay_topic topic

    elsif topic.generated_news_topic?
      generated_news_topic topic

    elsif topic.news_topic?
      news_topic topic

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

  def cosplay_topic topic
    Topics::CosplayView.new topic, is_preview, is_mini
  end

  def generated_news_topic topic
    Topics::GeneratedNewsView.new topic, is_preview, is_mini
  end

  def news_topic topic
    Topics::NewsView.new topic, is_preview, is_mini
  end

  def common_topic topic
    Topics::View.new topic, is_preview, is_mini
  end
end
