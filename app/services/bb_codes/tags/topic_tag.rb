class BbCodes::Tags::TopicTag < BbCodes::Tags::CommentTag
  klass Topic

  def name_regexp
    "(?:#{name}|entry)"
  end

  def entry_id_url _entry_id
    nil
  end
end
