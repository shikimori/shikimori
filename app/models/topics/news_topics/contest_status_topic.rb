class Topics::NewsTopics::ContestStatusTopic < Topics::NewsTopic
  enumerize :action,
    in: Types::Topic::NewsTopic::ContestStatusTopic::Action.values,
    predicates: true

  def title
    I18n.t "topics/contest_status_topic.title.#{action}"
  end
end
