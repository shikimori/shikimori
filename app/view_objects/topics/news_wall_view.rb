class Topics::NewsWallView < Topics::NewsView
  def container_class css = nil
    super ['b-news_wall-topic', css]
  end

  def html_footer
    BbCodes::Text.call(
      (@topic.decomposed_body.wall ?
        @topic.decomposed_body.wall.gsub(%r{(\[wall\]\[.*?\]).*?(\[/wall\])}, '\1\2') :
        '[wall][/wall]'
      )
    )
      .gsub('b-shiki_wall', 'b-shiki_swiper')
      .gsub('data-dynamic="wall"', 'data-dynamic="swiper"')
      .gsub('<a', '<span')
      .gsub('</a>', '</span>')
      .html_safe
  end
end
