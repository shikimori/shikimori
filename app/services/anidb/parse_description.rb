# frozen_string_literal: true

class Anidb::ParseDescription
  include ChainableMethods
  method_object :url

  REQUIRED_TEXT = 'AniDB</title>'
  UNKNOWN_ID_TEXTS = ['Unknown anime id', 'Unknown character id']
  CAPTCHA_TEXT = 'This website is for humans only'
  ADULT_CONTENT_TEXT = 'Adult Content Warning'
  AUTO_BANNED_TEXT = 'AniDB AntiLeech'

  DESCRIPTION_XPATH = "//div[@itemprop='description']"

  def call
    chain_from(get).parse.sanitize.unwrap
  end

  private

  def get
    content = get_with_proxy!(url)
    content = get_authorized!(url) if adult_content?(content)
    content
  end

  def get_with_proxy! url
    options = { no_proxy: Rails.env.test?, required_text: REQUIRED_TEXT }
    content = Proxy.get(url, options)

    raise EmptyContentError, url if content.blank?
    raise InvalidIdError, url if unknown_id?(content)
    raise CaptchaError, url if captcha?(content)

    content
  end

  def get_authorized! url
    headers = { 'Cookie' => Anidb::Authorization.instance.cookie.join }
    content = open(url, headers).read

    raise AutoBannedError, url if auto_banned?(content)

    content
  end

  def parse content
    doc(content).at_xpath(DESCRIPTION_XPATH).inner_html
  end

  def sanitize html
    Anidb::SanitizeText.call html
  end

  def unknown_id? content
    UNKNOWN_ID_TEXTS.any? { |v| content.include?(v) }
  end

  def captcha? content
    content.include? CAPTCHA_TEXT
  end

  def adult_content? content
    content.include? ADULT_CONTENT_TEXT
  end

  def auto_banned? content
    content.include? AUTO_BANNED_TEXT
  end

  def doc content
    @doc ||= Nokogiri.HTML(content)
  end
end
