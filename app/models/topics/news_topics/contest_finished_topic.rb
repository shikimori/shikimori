class Topics::NewsTopics::ContestFinishedTopic < Topics::NewsTopic
  def title
    I18n.t 'topics/contest_finished_topic.title'
  end
end
