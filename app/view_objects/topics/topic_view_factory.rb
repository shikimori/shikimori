class Topics::TopicViewFactory
  pattr_initialize :is_preview, :is_mini

  def find topic_id
    build Topic.find(topic_id)
  end

  def build topic
    if topic.review?
      Topics::ReviewView.new topic, is_preview, is_mini

    elsif topic.contest?
      Topics::ContestView.new topic, is_preview, is_mini

    elsif topic.cosplay?
      Topics::CosplayView.new topic, is_preview, is_mini

    elsif topic.generated_news?
      Topics::GeneratedNewsView.new topic, is_preview, is_mini

    elsif topic.news?
      Topics::NewsView.new topic, is_preview, is_mini

    else
      Topics::View.new topic, is_preview, is_mini
    end
  end
end
