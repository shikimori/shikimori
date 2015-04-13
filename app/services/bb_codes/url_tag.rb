class BbCodes::UrlTag
  include Singleton

  REGEXP = /
      \[url\]
        (?<url> .*?)
      \[\/url\]
    |
      \[url=(?<url>.*?)\]
        (?<text> [\s\S]*?)
      \[\/url\]
    |
      (?<= \s|^|>)
        (?<url>
          https?:\/\/(?:www\.)?
          ( [^\s<\[\].,;:] | [.,;:] (?!=\s|$|<|\[|\]) )+
        )
  /imx

  def format text
    text.gsub REGEXP do
      url = $~[:url]
      text = $~[:text] || $~[:url].extract_domain

      "<a href=\"#{url}\">#{text}</a>"
    end
  end
end
