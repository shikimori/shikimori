class Topics::EntryTopics::ReviewTopic < Topics::EntryTopic
  def title
    linked.target.name
  end
end
