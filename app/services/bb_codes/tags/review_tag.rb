class BbCodes::Tags::ReviewTag < BbCodes::Tags::CommentTag
  klass Review

  def entry_url entry
    UrlGenerator.instance.review_url entry
  end
end
