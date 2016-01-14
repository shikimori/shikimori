class Topics::EntryTopic < Topic
  def title
    I18n.t 'topics/entry_topic.title'
  end

  def body
    I18n.t "topics/entry_topic.body.#{linked_type.underscore}",
      id: linked_id,
      type: linked_type.underscore
  end
end
