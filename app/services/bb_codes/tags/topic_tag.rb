class BbCodes::Tags::TopicTag < BbCodes::Tags::CommentTag
  klass Topic

  def name_regexp
    "(?:#{name}|entry)"
  end
end
