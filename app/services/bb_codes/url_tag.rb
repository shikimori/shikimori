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
      url = if $~[:url].starts_with? '/'
        $~[:url]
      else
        $~[:url].with_http
      end

      text = if $~[:text]
        $~[:text]
      else
        if url.without_http =~ /(\w+\.)?shikimori.\w+\/(?<path>.+)/
          "/#{$~[:path]}"
        else
          url.size > MAX_SHORT_URL_SIZE ? url.extract_domain : url.without_http
        end
      end

      decoded_text = URI.decode text
      "<a class=\"b-link\" href=\"#{url}\">#{decoded_text.valid_encoding? ? decoded_text : url.extract_domain}</a>"
    end
  end
end
