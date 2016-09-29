class BbCodes::ImgTag
  include Singleton

  REGEXP = %r{
      \[url=(?<link_url>[^\[\]]+)\]
        \[img\]
          (?<image_url>[^\[\]].*?)
        \[/img\]
      \[/url\]
    |
      \[
        img
        (?:
          (?: \s c(?:lass)?=(?<klass>[\w_-]+) )? |
          (?: \s (?<width>\d+)x(?<height>\d+) )? |
          (?: \s w(?:idth)?=(?<width>\d+) )? |
          (?: \s h(?:eight)?=(?<height>\d+) )?
        )*
      \]
        (?<image_url>[^\[\]].*?)
      \[/img\]
  }imx

  def format text, text_hash
    text.gsub REGEXP do
      if $LAST_MATCH_INFO[:link_url]
        html_for_image(
          $LAST_MATCH_INFO[:image_url], $LAST_MATCH_INFO[:link_url],
          0, 0,
          nil, text_hash
        )
      else
        html_for_image(
          $LAST_MATCH_INFO[:image_url], nil,
          $LAST_MATCH_INFO[:width].to_i, $LAST_MATCH_INFO[:height].to_i,
          $LAST_MATCH_INFO[:klass], text_hash
        )
      end
    end
  end

private

  def html_for_image image_url, link_url, width, height, klass, text_hash
    camo_url = UrlGenerator.instance.camo_url(fix_url(image_url))
    if link_url =~ %r{shikimori\.(\w+)/.*\.(?:jpg|png)}
      camo_link_url = UrlGenerator.instance.camo_url(fix_url(link_url))
    end

    sizes_html = ''
    sizes_html += " width=\"#{width}\"" if width.positive?
    sizes_html += " height=\"#{height.to_i}\"" if height.positive?
    css_class = [
      ('check-width' unless sizes_html.present?),
      (klass if klass.present?)
    ].compact.join(' ')

    <<-HTML.squish.strip
      <a href="#{link_url || image_url}"
        data-href="#{camo_link_url || camo_url}"
        rel="#{text_hash}"
        class="b-image unprocessed"><img
        src="#{camo_url}" class="#{css_class}"#{sizes_html}></a>
    HTML
  end

  def fix_url url
    url =~ %r{\A(https?:)?//} ? url : Url.new(url).with_http.to_s
  end
end
