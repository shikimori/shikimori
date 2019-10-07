class Topics::NewsWallView < Topics::NewsView
  def container_class css = nil
    super ['b-news_wall-topic', css]
  end

  def show_buttons?
    false
  end

  def show_body?
    false
  end

  def show_source?
    false
  end
end
