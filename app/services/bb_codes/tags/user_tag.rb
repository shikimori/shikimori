class BbCodes::Tags::UserTag < BbCodes::Tags::CommentTag
  klass User
  user_field :itself
  includes_scope false

  def entry_url entry
    UrlGenerator.instance.profile_url entry
  end

  def entry_id_url _entry_id
  end
end
