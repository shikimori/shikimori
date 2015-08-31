class BbCodes::UrlTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  REGEXP = /
      \[url\]
        (?<url> .*?)
      \[\/url\]
    |
      \[url=(?<url>.*?)\]
        (?<text> .*?)
      \[\/url\]
    |
      (?<= \s|^|>|\()
        (?<url>
          https?:\/\/(?:www\.)?
          ( [^\s<\[\].,;:)(] | [.,;:)(] (?!=\s|$|<|\[|\]|\ ) )+
        )
  /mix

  def format text
    text.gsub REGEXP do
      url = match_url $~[:url]
      text = match_text $~[:text], url

      url.ends_with?('.webm') ? video_bb_code(url) : link_tag(url, text)
    end
  end

private

  def link_tag url, text
    decoded_text = URI.decode text
    "<a class=\"b-link\" href=\"#{url}\">#{decoded_text.valid_encoding? ? decoded_text : url.extract_domain}</a>"
  end

  def video_bb_code url
    "[html5_video]#{url}[/html5_video]"
  end

  def match_url url
    url.starts_with?('/') ? url : url.with_http
  end

  def match_text text, url
    return text if text

    if url.without_http =~ /(\w+\.)?shikimori.\w+\/(?<path>.+)/
      "/#{$~[:path]}"
    else
      url.size > MAX_SHORT_URL_SIZE ? url.extract_domain : url.without_http
    end
  end
end
