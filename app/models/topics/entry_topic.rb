class Topics::EntryTopic < Topic
  def title
    I18n.t 'topics/entry_topic.title'
  end

  # для message
  def full_title
    fail ArgumentError unless generated?

    BbCodeFormatter.instance.format_comment(I18n.t(
      "topics/entry_topic.full_title.#{linked_type.underscore}",
      id: linked_id,
      type: linked_type.underscore
    )).gsub(/<.*?>/, '')
  end

  def body
    I18n.t "topics/entry_topic.body.#{linked_type.underscore}",
      id: linked_id,
      type: linked_type.underscore
  end
end
