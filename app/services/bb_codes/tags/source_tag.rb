class BbCodes::Tags::SourceTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  REGEXP = /
    \[source\]
      (?<url> #{BbCodes::Tags::UrlTag::URL_SYMBOL_CLASS}*?)
    \[\/source\]
  /mix

  def format text
    text.gsub REGEXP do
      url = match_url $LAST_MATCH_INFO[:url]

      <<~HTML.squish
        <div class="b-source hidden"><span class="linkeable"
        data-href="#{url}">#{Url.new(url).domain}</span></div>
      HTML
    end
  end

private

  def match_url url
    url.starts_with?('/') ? url : Url.new(url).with_http.to_s
  end
end
