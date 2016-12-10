class Anidb::ParseDescription
  UNKNOWN_ID_ERRORS = ['Unknown anime id', 'Unknown character id']
  DESCRIPTION_XPATH = "//div[@itemprop='description']"

  def call url
    content = get(url)
    html = parse(content)
    sanitize(html)
  end

  private

  def get url
    content = Proxy.get(url, proxy_options)
    raise EmptyContentError.new(url) if content.blank?
    raise InvalidIdError.new(url) if unknown_id?(content)

    content
  end

  def parse content
    doc(content).at_xpath(DESCRIPTION_XPATH).inner_html
  end

  def sanitize html
    Mal::TextSanitizer.new(html).()
  end

  def proxy_options
    { ban_texts: MalFetcher.ban_texts, no_proxy: Rails.env.test? }
  end

  def unknown_id? content
    UNKNOWN_ID_ERRORS.any? { |v| content.include?(v) }
  end

  def doc content
    @doc ||= Nokogiri.HTML(content)
  end
end
