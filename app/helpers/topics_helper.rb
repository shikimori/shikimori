module TopicsHelper
  def subforum_url topic
    forum_url forum: topic.forum, linked: topic.linked
  end

  def topic_url topic, format = nil
    UrlGenerator.instance.topic_url topic, format
  end

  # фиксы для урлов STI
  def anime_news_path *args
    topic_path(*args)
  end
  def manga_news_path *args
    topic_path(*args)
  end
end
