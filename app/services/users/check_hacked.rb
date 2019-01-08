class Users::CheckHacked
  include Translation
  method_object %i[model! text! user!]

  SPAM_DOMAINS = %w[
    shikme.ru
    shikkme.ru
    hikanime.ru
    shikme.chatree.net
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
    smotretanime.ru
    vimeo.com
    vk.com
    yandex.ru
    youtu.be
    youtube.com
    radikal.ru
  ]

  def call
    if spam?
      @model.errors.add :base, ban_text
      Users::LockHacked.perform_async @user.id
      NamedLogger.hacked.info @model.attributes.to_yaml

      false
    else
      true
    end
  end

private

  def spam?
    (
      domains(follow(links(@text))) & SPAM_DOMAINS
    ).any?
  end

  def ban_text
    i18n_t :lock_text,
      email: Shikimori::EMAIL,
      locale: @user.locale,
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
