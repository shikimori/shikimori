class BbCodes::Tags::TopicTag < BbCodes::Tags::CommentTag
  klass Topic

  def name_regexp
    "(?:#{name}|entry)"
  end

  def entry_id_url entry_id
    UrlGenerator.instance.forum_topic_url(
      id: entry_id,
      forum: Forum.find_by_permalink('offtopic') # rubocop:disable Rails/DynamicFindBy
    )
  end
end
