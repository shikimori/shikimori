class Messages::CheckHacked
  include Translation
  method_object :message

  SPAM_DOMAINS = %w[
    shikme.ru
    shikkme.ru
    hikanime.ru
  ]
  NOT_SPAM_DOMAINS = %w[
    animenewsnetwork.com
    google.com
    google.ru
    mail.ru
    myanimelist.net
    myvi.ru
    rutube.ru
    sibnet.ru
    smotret-anime.ru
    vimeo.com
    vk.com
    yandex.ru
    youtu.be
    youtube.com
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
      email: Shikimori::EMAIL,
      locale: message.from.locale,
      recovery_url: UrlGenerator.instance.new_user_password_url(
        protocol: Shikimori::PROTOCOL
      )
  end

  def links html
    html
      .scan(BbCodes::Tags::UrlTag::URL)
      .map(&:first)
      .reject { |v| NOT_SPAM_DOMAINS.include? Url.new(v).domain.cut_www.to_s }
  end

  def follow urls
    urls.map do |url|
      Rails.cache.fetch([url, :follow]) { Network::FinalUrl.call(url) || url }
    end
  end

  def domains urls
    urls
      .select(&:present?)
      .map { |url| Url.new(url).domain.to_s }
  end
end
