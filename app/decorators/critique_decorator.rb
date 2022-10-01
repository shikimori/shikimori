class CritiqueDecorator < DbEntryDecorator
  def url
    UrlGenerator.instance.topic_url topic
  end
end
