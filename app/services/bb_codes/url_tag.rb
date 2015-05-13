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
      (?<= \s|^|>)
        (?<url>
          https?:\/\/(?:www\.)?
          ( [^\s<\[\].,;:)(] | [.,;:)(] (?!=\s|$|<|\[|\]|\ ) )+
        )
  /mix

  def format text
    text.gsub REGEXP do
      url = $~[:url]

      text = if $~[:text]
        $~[:text]
      else
        url = $~[:url]

        if url.without_http =~ /(\w+\.)?shikimori.\w+\/(?<path>.+)/
          "/#{$~[:path]}"
        else
          url.size > MAX_SHORT_URL_SIZE ? url.extract_domain : url.without_http
        end
      end

      "<a href=\"#{url}\">#{URI.decode text}</a>"
    end
  end
end
