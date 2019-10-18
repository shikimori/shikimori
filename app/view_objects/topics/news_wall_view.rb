class Topics::NewsWallView < Topics::NewsView
  def container_class css = nil
    super ['b-news_wall-topic', css]
  end

  def html_footer
    BbCodes::Text.call(wall_bb_code)
      .gsub('b-shiki_wall', 'b-shiki_swiper')
      .gsub('data-dynamic="wall"', 'data-dynamic="swiper"')
      .gsub('<a', '<span')
      .gsub('</a>', '</span>')
      .html_safe
  end

private

  def wall_bb_code
    bb_code = @topic.decomposed_body.wall

    if bb_code.present?
      bb_code.gsub(%r{(\[wall\]\[.*?\]).*?(\[/wall\])}, '\1\2')
    else
      '[wall][/wall]'
    end
  end
end
