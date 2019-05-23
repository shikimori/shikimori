class BbCodes::Tags::UrlTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  BEFORE_URL = /(?<= \s|^|>|\()/
  URL_SYMBOL_CLASS = /[^"'<>\[\]]/.source
  URL = %r{
    (?<url>
      (?: https?: )?
      //
      (?:www\.)?
      ( [^\s<\[\].,;:)(] | [.,;:)(] (?!=\s|$|[<\[\]\ ;,]) )+
    )
  }mix

  REGEXP = %r{
    \[ url (?:\ (?<class>[\w_\ -]+))? \]
      (?<url> #{URL_SYMBOL_CLASS}*? )
    \[/url\]
      |
    \[ url=(?<url>#{URL_SYMBOL_CLASS}*? ) (?:\ (?<class>[\w_\ -]+))? \]
      (?<text> .*? )
    \[/url\]
      |
    #{BEFORE_URL.source} #{URL.source}
  }mix

  def format text
    text.gsub REGEXP do
      url = match_url $LAST_MATCH_INFO[:url]
      text = match_text $LAST_MATCH_INFO[:text], url
      css_class = $LAST_MATCH_INFO[:class]

      webm_link?(url) ? video_bb_code(url) : link_tag(url, text, css_class)
    end
  end

private

  def link_tag url, text, css_class
    link_text = decode_uri text
    css_classes = ['b-link', css_class].select(&:present?).join(' ')

    if !link_text.valid_encoding? || link_text.blank?
      link_text = url.starts_with?('/') ? url : Url.new(url).domain
    end

    <<~HTML.strip
      <a class="#{css_classes}" href="#{url}">#{link_text}</a>
    HTML
  end

  def video_bb_code url
    "[html5_video]#{url}[/html5_video]"
  end

  def match_url url
    if url.starts_with?('/')
      url
    elsif Url.new(url).without_http.to_s =~ %r{(\w+\.)?shikimori\.\w+/(?<path>.+)}
      "/#{$LAST_MATCH_INFO[:path]}"
    else
      Url.new(url).with_http.to_s
    end
  end

  def match_text text, url
    return text if text

    if Url.new(url).without_http.to_s =~ %r{(\w+\.)?shikimori\.\w+/(?<path>.+)}
      "/#{$LAST_MATCH_INFO[:path]}"
    elsif url.size > MAX_SHORT_URL_SIZE
      Url.new(url).domain.to_s
    else
      Url.new(url).without_http.to_s
    end
  end

  def decode_uri text
    URI.decode text
  rescue Encoding::CompatibilityError
    text
  end

  def webm_link? url
    url.ends_with?('.webm') || url.ends_with?('.mp4')
  end
end
