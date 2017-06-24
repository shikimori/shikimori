class Topics::NewsTopics::ContestStatusTopic < Topics::NewsTopic
  include Translation

  enumerize :action,
    in: Types::Topic::NewsTopic::ContestStatusTopic::Action.values,
    predicates: true

  def title
    i18n_t "title.#{action}"
  end
end
