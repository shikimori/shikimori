class Topics::EntryTopics::ReviewTopic < Topics::EntryTopics::CritiqueTopic
  def title
    linked.db_entry.name
  end

  def full_title
    first_key = linked_type.underscore
    second_key = linked.db_entry.class.name.underscore

    I18n.t(
      "topics/entry_topic.full_title.#{first_key}.#{second_key}",
      target_name: title,
      author: linked.user.nickname
    )
  end
end
