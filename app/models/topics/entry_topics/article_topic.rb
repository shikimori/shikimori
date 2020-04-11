class Topics::EntryTopics::ArticleTopic < Topics::EntryTopic
  def body
    linked.body
  end
end
