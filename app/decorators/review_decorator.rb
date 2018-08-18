class ReviewDecorator < DbEntryDecorator
  def url
    UrlGenerator.instance.topic_url topic(locale)
  end
end
