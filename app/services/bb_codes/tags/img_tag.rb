class BbCodes::Tags::ImgTag
  include Singleton

  REGEXP = %r{
      \[url=(?<link_url>#{BbCodes::Tags::UrlTag::URL_SYMBOL_CLASS}+)\]
        \[img\]
          (?<image_url> [^\[\],. ] .*? )
        \[/img\]
      \[/url\]
    |
      \[
        img
        (?:
          (?: \s c(?:lass)?=(?<css_class>[\w_-]+) )? |
          (?: \s (?<width>\d+)x(?<height>\d+) )? |
          (?: \s w(?:idth)?=(?<width>\d+) )? |
          (?: \s h(?:eight)?=(?<height>\d+) )? |
          (?<no_zoom> \s no-zoom )?
        )*
      \]
        (?<image_url> [^\[\],. ] .*? )
      \[/img\]
  }imx

  def format text, text_hash
    text.gsub REGEXP do
      html_for(
        escaped_image_url: $LAST_MATCH_INFO[:image_url],
        link_url: $LAST_MATCH_INFO[:link_url],
        width: $LAST_MATCH_INFO[:width].to_i,
        height: $LAST_MATCH_INFO[:height].to_i,
        css_class: $LAST_MATCH_INFO[:css_class],
        is_no_zoom: $LAST_MATCH_INFO[:no_zoom].present?,
        text_hash: text_hash
      )
    end
  end

private

  def html_for( # rubocop:disable all
    escaped_image_url:,
    link_url:,
    width:,
    height:,
    css_class:,
    is_no_zoom:,
    text_hash:
  )
    image_url = CGI.unescapeHTML escaped_image_url
    fixed_image_url = camo_url image_url
    safe_image_url = fixed_image_url.html_safe? ?
      fixed_image_url :
      ERB::Util.h(fixed_image_url)

    camo_link_url = camo_url link_url if link_url&.match? %r{shikimori\.(\w+)/.*\.(?:jpg|png|webp)}
    image_html = html_for_image safe_image_url, width, height
    attrs = { src: image_url }

    if is_no_zoom
      <<~HTML.squish
        <span class='b-image no-zoom#{" #{ERB::Util.h css_class}" if css_class.present?}'
          data-attrs='#{attrs.to_json}'>#{image_html}</span>
      HTML
    else
      <<~HTML.squish
        <a href='#{ERB::Util.h(link_url || image_url)}'
          data-href='#{camo_link_url || safe_image_url}'
          rel='#{text_hash}'
          class='b-image unprocessed#{" #{ERB::Util.h css_class}" if css_class.present?}'
          data-attrs='#{attrs.to_json}'>#{image_html}</a>
      HTML
    end
  end

  def html_for_image safe_image_url, width, height
    sizes_html = ''
    sizes_html += " width='#{width}'" if width.positive?
    sizes_html += " height='#{height.to_i}'" if height.positive?

    <<-HTML.squish.strip
      <img src='#{safe_image_url}'
        class='check-width'#{sizes_html} loading='lazy'>
    HTML
  end

  def camo_url image_url
    UrlGenerator.instance.camo_url fix_url(image_url)
  end

  def fix_url url
    url.match?(%r{\A(https?:)?//}) ?
      url :
      Url.new(url).with_http.to_s
  end
end
