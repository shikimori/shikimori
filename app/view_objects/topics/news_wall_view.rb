class Topics::NewsWallView < Topics::NewsView
  instance_cache :html_wall
  # , :basic_tags, :other_tags

  def container_class css = nil
    ['b-news_wall-topic', css]
  end

  # def basic_tags
  #   @topic.tags & Topics::TagsQuery::BASIC_TAGS
  # end

  # def other_tags
  #   @topic.tags - basic_tags
  # end

  def html_wall
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
