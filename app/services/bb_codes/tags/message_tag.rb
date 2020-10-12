class BbCodes::Tags::MessageTag < BbCodes::Tags::CommentTag
  klass Message
  user_field :from

  def entry_url entry
    UrlGenerator.instance.message_url entry.id
  end
end
