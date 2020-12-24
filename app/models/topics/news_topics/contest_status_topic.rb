class Topics::NewsTopics::ContestStatusTopic < Topics::NewsTopic
  include Translation

  enumerize :action,
    in: Types::Topic::ContestStatusTopic::Action.values,
    predicates: true

  def title
    i18n_t "title.#{action}"
  end

  def full_title
    "#{title} #{linked.title}"
  end

  def body
    '[wall][wall_image=1316293][/wall]'
  end
end
