class Topics::EntryTopics::ReviewTopic < Topics::EntryTopic
  def title
    linked.target.name
  end

  def full_title
    fail ArgumentError unless generated?
    first_key = linked_type.underscore
    second_key = linked.target_type.underscore

    I18n.t(
      "topics/entry_topic.full_title.#{first_key}.#{second_key}",
      target_name: title,
      author: linked.user.nickname
    )
  end
end
