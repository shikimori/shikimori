class BbCodes::UrlTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  REGEXP = %r{
    \[url\]
      (?<url> .*?)
    \[/url\]
      |
    \[url=(?<url>.*?)\]
      (?<text> .*?)
    \[/url\]
      |
    (?<= \s|^|>|\()
      (?<url>
        (?: https?: )
        ?//(?:www\.)?
        ( [^\s<\[\].,;:)(] | [.,;:)(] (?!=\s|$|<|\[|\]|\ |;) )+
      )
  }mix

  def format text
    text.gsub REGEXP do
      url = match_url $LAST_MATCH_INFO[:url]
      text = match_text $LAST_MATCH_INFO[:text], url

      url.ends_with?('.webm') ? video_bb_code(url) : link_tag(url, text)
    end
  end

private

  def link_tag url, text
    decoded_text = URI.decode text rescue Encoding::CompatibilityError
    decoded_text ||= text

    "<a class=\"b-link\" href=\"#{url}\">\
#{decoded_text.valid_encoding? ? decoded_text : Url.new(url).extract_domain}</a>"
  end

  def video_bb_code url
    "[html5_video]#{url}[/html5_video]"
  end

  def match_url url
    url.starts_with?('/') ? url : Url.new(url).with_http.to_s
  end

  def match_text text, url
    return text if text

    if Url.new(url).without_http.to_s =~ %r{(\w+\.)?shikimori.\w+/(?<path>.+)}
      "/#{$LAST_MATCH_INFO[:path]}"
    else
      url.size > MAX_SHORT_URL_SIZE ? url.extract_domain : url.without_http
    end
  end
end
