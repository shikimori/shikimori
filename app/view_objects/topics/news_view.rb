class Topics::NewsView < Topics::View
  def container_class
    super 'b-news-topic'
  end

  def minified?
    is_preview || is_mini
  end

  def topic_title
    topic.title
  end
end
