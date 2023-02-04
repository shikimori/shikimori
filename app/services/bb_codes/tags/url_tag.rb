class BbCodes::Tags::UrlTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  BEFORE_URL = /(?<= \s|^|>|\( )/
  AFTER_URL = /(?= \s|$|<|\) )/

  URL_SYMBOL_CLASS = /[^"'<>\[\]]/.source
  URL = %r{
    (?<url>
      (?: https?: )?
      //
      (?:www\.)?
      (?: [^\s<\[\].,;:)(] | [.,;:)(] (?!=\s|$|[<\[\]\ ;,]) )+
    )
  }mix

  REGEXP = %r{
    \[ url (?:\ (?<css_class>[\w_\ -]+))? \]
      (?<url> #{URL_SYMBOL_CLASS}*? )
    \[/url\]
      |
    \[ url=(?<url>#{URL_SYMBOL_CLASS}*? ) (?:\ (?<css_class>[\w_\ -]+))? \]
      (?<text> .*? )
    \[/url\]
      |
    #{BEFORE_URL.source} #{URL.source}
  }mix

  REL = ' rel="noopener noreferrer nofollow"'

  def format text
    text.gsub REGEXP do
      escaped_url, is_shikimori = match_url $LAST_MATCH_INFO[:url]
      url = CGI.unescapeHTML escaped_url
      text = match_text $LAST_MATCH_INFO[:text], url
      css_class = BbCodes::CleanupCssClass.call $LAST_MATCH_INFO[:css_class]

      webm_link?(url) ?
        video_bb_code(escaped_url) :
        link_tag(url, text, css_class, is_shikimori)
    end
  end

private

  def link_tag url, text, css_class, is_shikimori
    link_text = decode_uri text
    css_classes = ['b-link', css_class].select(&:present?).join(' ')

    if !link_text.valid_encoding? || link_text.blank?
      link_text = url.starts_with?('/') ? url : Url.new(url).domain
    end

    <<~HTML.squish
      <a class="#{css_classes}"
        href="#{ERB::Util.h url}"#{REL unless is_shikimori}>#{ERB::Util.h link_text}</a>
    HTML
  end

  def video_bb_code escaped_url
    "[html5_video]#{escaped_url}[/html5_video]"
  end

  def match_url url
    if url.starts_with?('/')
      [url, !url.starts_with?('//')]
    elsif Url.new(url).without_http.to_s =~ %r{(?:\w+\.)?shikimori\.\w+/(?<path>.+)}
      ["/#{$LAST_MATCH_INFO[:path]}", true]
    else
      [Url.new(url).with_http.to_s, false]
    end
  end

  def match_text text, url
    return CGI.unescapeHTML(text) if text

    if Url.new(url).without_http.to_s =~ %r{(?:\w+\.)?shikimori\.\w+/(?<path>.+)}
      "/#{$LAST_MATCH_INFO[:path]}"
    elsif url.size > MAX_SHORT_URL_SIZE
      Url.new(url).domain.to_s
    else
      Url.new(url).without_http.to_s
    end
  end

  def decode_uri text
    Addressable::URI.unencode text
  rescue Encoding::CompatibilityError
    text
  end

  def webm_link? url
    url.ends_with?('.webm') || url.ends_with?('.mp4')
  end
end
