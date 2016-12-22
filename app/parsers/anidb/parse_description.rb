# frozen_string_literal: true

class Anidb::ParseDescription
  include ChainableMethods
  method_object :url

  UNKNOWN_ID_ERRORS = ['Unknown anime id', 'Unknown character id']
  DESCRIPTION_XPATH = "//div[@itemprop='description']"

  def call
    chain_from(get).parse.sanitize.unwrap
  end

  private

  def get
    content = Proxy.get(url, proxy_options)

    raise EmptyContentError, url if content.blank?
    raise InvalidIdError, url if unknown_id?(content)

    content
  end

  def parse content
    doc(content).at_xpath(DESCRIPTION_XPATH).inner_html
  end

  def sanitize html
    Anidb::SanitizeText.new.(html)
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
