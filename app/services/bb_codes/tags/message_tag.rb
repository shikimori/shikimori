class BbCodes::Tags::MessageTag < BbCodes::Tags::CommentTag
  klass Message
  user_field :from

  def entry_url entry, _entry_id
    UrlGenerator.instance.profile_url entry.from
  end
end
