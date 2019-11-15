class Topics::NewsLineView < Topics::View
  instance_cache :view

  def container_classes additional = []
    ['b-news_line-topic', *additional]
  end

  def view
    Topics::TopicViewFactory.new(@is_preview, @is_mini).buid @topic
  end
end
