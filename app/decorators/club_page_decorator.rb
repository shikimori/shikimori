class ClubPageDecorator < BaseDecorator
  instance_cache :preview_topic_view

  def preview_topic_view
    Topics::TopicViewFactory.new(true, false).build object.topic
  end
end
