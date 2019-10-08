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

  def html_footer
    (@topic.decomposed_body.wall ? super : BbCodes::Text.call('[wall][/wall]'))
      .gsub('b-shiki_wall', 'b-shiki_swiper')
      .gsub('data-dynamic="wall"', 'data-dynamic="swiper"')
      .html_safe
  end
end
