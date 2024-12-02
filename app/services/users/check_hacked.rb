class Users::CheckHacked
  include Translation
  method_object %i[model! text! user!]

  SPAM_DOMAINS = %w[
    shikme.ru
    shikkme.ru
    hikanime.ru
    shikme.chatree.net
    shikme.chatchu.com
    shikme.loli.su
    shikme.aen.su
    shikme.tru.io
    shikme.z86.ru
    shikme.naru.to
    shiki.morry.ru
    dream69.xyz
    dream69.fun
  ]
  SPAM_LINKS = %w[
    discord.com/invite/4mgGDtjpaS
    discord.com/invite/hVybUWQQGS
    discord.com/invite/bCj6hMUGHR
    discord.gg/HY8Jq8rHuM
    discord.gg/jfqC3zemym
    discord.gg/sphGbbkUnq
    discord.gg/F8b975nnP5
    discord.gg/bCj6hMUGHR
  ]
  NOT_SPAM_DOMAINS = %w[
    shikimori.org
    shikimori.one
    animenewsnetwork.com
    google.com
    google.ru
    mail.ru
    myanimelist.net
    rutube.ru
    sibnet.ru
    smotretanime.ru
    vimeo.com
    vk.com
    yandex.ru
    youtu.be
    youtube.com
    radikal.ru
    cdjapan.co.jp
    neowing.co.jp
    amazon.co.jp
  ] + Shikimori::ALLOWED_DOMAINS.flat_map do |domain|
    [domain] + Shikimori::STATIC_SUBDOMAINS
      .map { |subdomain| "#{subdomain}.#{domain}" }
      .uniq
  end

  LINKS_CHECK_LIMIT = 7

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
    links = follow(links(@text))

    domains(links).intersect?(SPAM_DOMAINS) ||
      wo_protocol(links).intersect?(SPAM_LINKS)
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
      .uniq
      .take(LINKS_CHECK_LIMIT)
  end

  def follow urls
    urls
      .flat_map do |url|
        Rails.cache.fetch([url, :follow]) { [url, Network::FinalUrl.call(url)] }
      end
      .compact_blank
  end

  def domains urls
    urls.map { |url| Url.new(url).domain.to_s }
  end

  def wo_protocol urls
    urls.map { |url| url.gsub(%r{\A(?:https?:)?//}, '') }
  end
end
