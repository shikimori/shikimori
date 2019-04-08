# frozen_string_literal: true

class Anidb::ParseDescription
  method_object :url

  REQUIRED_TEXT = 'AniDB</title>'
  UNKNOWN_ID_TEXTS = ['Unknown anime id', 'Unknown character id']
  CAPTCHA_TEXT = 'This website is for humans only'
  ADULT_CONTENT_TEXT = 'Adult Content Warning'
  AUTO_BANNED_TEXT = 'AniDB AntiLeech'

  DESCRIPTION_XPATH = "//div[@itemprop='description']"

  HEADERS_WHEN_AUTHORIZED = {
    'Accept' => 'text/html,application/xhtml+xml,application/xml;'\
      'q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language' => 'en-US,en;q=0.8,ru;q=0.6,ja;q=0.4',
    'Connection' => 'keep-alive',
    'Host' => 'anidb.net',
    'Upgrade-Insecure-Requests' => '1',
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) '\
      'AppleWebKit/537.36 (KHTML, like Gecko) '\
      'Chrome/56.0.2924.87 Safari/537.36'
  }

  def call
    sanitize(parse(get))
  end

  private

  def get
    content = get_with_proxy!(url)
    content = get_authorized!(url) if adult_content?(content)
    content
  rescue OpenURI::HTTPError => e
    raise InvalidIdError, "#{e.message} (#{url})", e.backtrace
  end

  def get_with_proxy! url
    options = { no_proxy: Rails.env.test?, required_text: REQUIRED_TEXT }
    content = Proxy.get(url, options)

    raise EmptyContentError, url if content.blank?
    raise InvalidIdError, url if unknown_id?(content)
    raise CaptchaError, url if captcha?(content)
    raise AutoBannedError, url if auto_banned?(content)

    content
  end

  def get_authorized! url
    cookie = Anidb::Authorization.instance.cookie_string
    headers = HEADERS_WHEN_AUTHORIZED.merge('Cookie' => cookie)
    content = OpenURI.open_uri(url, headers).read

    raise CaptchaError, url if captcha?(content)
    raise AutoBannedError, url if auto_banned?(content)

    content
  end

  def parse content
    doc(content).at_xpath(DESCRIPTION_XPATH)&.inner_html || ''
  end

  def sanitize html
    Anidb::SanitizeText.call html
  end

  def unknown_id? content
    UNKNOWN_ID_TEXTS.any? { |v| content.include?(v) }
  end

  def adult_content? content
    content.include? ADULT_CONTENT_TEXT
  end

  def captcha? content
    content.include? CAPTCHA_TEXT
  end

  def auto_banned? content
    content.include? AUTO_BANNED_TEXT
  end

  def doc content
    @doc ||= Nokogiri.HTML(content)
  end
end
