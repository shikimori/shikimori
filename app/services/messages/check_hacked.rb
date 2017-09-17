class Messages::CheckHacked
  include Translation
  method_object :message

  SPAM_DOMAINS = %w[
    shikme.ru
  ]

  def call
    if spam? @message
      @message.errors.add :base, ban_text(@message)
      Users::LockHacked.perform_async @message.from_id
      NamedLogger.hacked.info @message.attributes.to_yaml

      false
    else
      true
    end
  end

private

  def spam? message
    return false unless message.kind == MessageType::Private
    (
      domains(follow(links(message.body))) & SPAM_DOMAINS
    ).any?
  end

  def ban_text message
    i18n_t :lock_text,
      email: Site::EMAIL,
      locale: message.from.locale,
      recovery_url: UrlGenerator.instance.new_user_password_url(
        protocol: Site::ALLOWED_PROTOCOL
      )
  end

  def links html
    html.scan(BbCodes::UrlTag::URL).map(&:first)
  end

  def follow urls
    urls.map do |url|
      Rails.cache.fetch([url, :follow]) { Network::FinalUrl.call(url) }
    end
  end

  def domains urls
    urls
     .select(&:present?)
     .map { |url| Url.new(url).domain.to_s }
  end
end
