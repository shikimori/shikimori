module TopicsHelper
  def subsection_url(topic)
    section_url section: topic.section, linked: topic.linked
  end

  def topic_url(topic, format = nil)
    if topic.kind_of?(User)
      profile_url topic
    elsif topic.kind_of?(ContestComment) || topic.news? || topic.review?
      section_topic_url section: topic.section, linked: nil, topic: topic, format: format
    else
      section_topic_url section: topic.section, linked: topic.linked, topic: topic, format: format
    end
  end

  # фиксы для урлов STI
  def anime_news_path(*args)
    topic_path *args
  end
  def manga_news_path(*args)
    topic_path *args
  end
end
