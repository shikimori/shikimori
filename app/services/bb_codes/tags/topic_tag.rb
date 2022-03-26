class BbCodes::Tags::TopicTag < BbCodes::Tags::CommentTag
  klass Topic

  def name_regexp
    "(?:#{name}|entry)"
  end

  def tooltip_url topic
    unless topic.is_a?(Topics::EntryTopics::CritiqueTopic) ||
        topic.is_a?(Topics::EntryTopics::ReviewTopic)
      return
    end

    UrlGenerator.instance.topic_tooltip_url topic
  end

  def entry_id_url entry_id
    UrlGenerator.instance.forum_topic_url(
      id: entry_id,
      forum: Forum.find_by_permalink('offtopic') # rubocop:disable Rails/DynamicFindBy
    )
  end
end
