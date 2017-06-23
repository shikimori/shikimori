class Topics::NewsTopics::ContestStartedTopic < Topics::NewsTopic
  def title
    I18n.t 'topics/contest_started_topic.title'
  end
end
