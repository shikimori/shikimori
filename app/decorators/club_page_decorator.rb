class ClubPageDecorator < BaseDecorator
  instance_cache :pcritique_topic_view

  CACHE_VERSION = :v3

  def pcritique_topic_view
    Topics::TopicViewFactory.new(true, false).build object.topic
  end
end
