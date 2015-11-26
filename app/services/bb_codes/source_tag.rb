class BbCodes::SourceTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  REGEXP = /
    \[source\]
      (?<url> .*?)
    \[\/source\]
  /mix

  def format text
    text.gsub REGEXP do
      url = match_url $~[:url]

      "<div class=\"b-source hidden\">\
<span class=\"linkeable\" data-href=\"#{url}\">\
#{url.extract_domain}</span></div>"
    end
  end

private

  def match_url url
    url.starts_with?('/') ? url : url.with_http
  end
end
