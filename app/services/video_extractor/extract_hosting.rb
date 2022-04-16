class VideoExtractor::ExtractHosting < ServiceObjectBase
  pattr_initialize :url
  instance_cache :domain

  REPLACEMENTS = {
    'vkontakte.ru' => 'vk.com',
    'mailru.ru' => 'mail.ru'
  }

  def call
    REPLACEMENTS[domain] || domain
  rescue URI::InvalidURIError
  end

private

  def domain
    parts = URI.parse(@url).host.split('.')
    "#{parts[-2]}.#{parts[-1]}"
  end
end
