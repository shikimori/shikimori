class ClubPageDecorator < BaseDecorator
  instance_cache :preview_topic_view

  CACHE_VERSION = :v3

  def preview_topic_view
    Topics::TopicViewFactory.new(true, false).build object.topic
  end
end
