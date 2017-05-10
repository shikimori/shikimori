class CollectionDecorator < DbEntryDecorator
  def minified_topic_view
    Topics::TopicViewFactory
      .new(true, true)
      .build(object.maybe_topic(h.locale_from_host))
  end
end
