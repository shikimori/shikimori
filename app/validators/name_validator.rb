class NameValidator < ActiveModel::EachValidator
  BANNED_NICKNAMES = %w[
    Youtoome
    shikimori
    shikimori.one
    shikimori.org
    shikimori.me
  ]
  PREDEFINED_PATHS = %i[
    .well-known
    a
    about
    achievements
    admin_log_in
    anime-industry
    anime-news
    animes
    apanel
    api
    articles
    assets
    autocomplete
    bb_codes
    c
    camo
    characters
    club_invites
    clubs
    collections
    comments
    comparer
    contests
    cosplay
    cosplay_galleries
    coubs
    country
    csrf_token
    dashboards
    development
    f
    facebook
    favicons
    faye
    faye-server
    faye-server-v1
    faye-server-v2
    faye-server-v3
    faye-server-v4
    faye-server-v5
    feedback
    for_right_holders
    forum
    g
    games
    hentai
    how_to_edit_achievements
    http_headers
    ignores
    imageboards
    images
    info
    javascripts
    kakie-anime-postmotret
    kakie-ranobe-pochitat
    kakuyu-mangu-pochitat
    log_in
    m
    mangas
    messages
    moderations
    my_target_ad
    news
    news_feed
    nginx_stub_status
    o
    oauth
    oauth_request
    oauth2
    ongoings
    p
    packs
    page404
    page503
    podcast
    polls
    privacy
    proxies
    proxy
    r
    raise_exception
    ranobe
    redirect
    reviews
    s
    site-news
    sitemap
    studios
    styles
    system
    tableau
    terms
    tests
    timeout_120s
    topics
    translations
    twitter
    uploads
    user_agent
    user_rates
    users
    v
    vn
    votes
    what_is_my_ip
  ]
  FORBIDDEN_NAMES = /
    \A(?:
      #{Forum::VARIANTS.join '|'} |
      #{PREDEFINED_PATHS.join '|'} |
      #{PREDEFINED_PATHS.map { |v| "#{v}\\.\\w+" }.join '|'} |
      #{BANNED_NICKNAMES.join '|'} |
    )\Z | (?:
      \.
      (?:#{FixName::ALL_EXTENSIONS.join('|')})
    \Z) | (?:
      \.\Z
    )
  /mix

  def validate_each record, attribute, value
    return unless value.is_a? String

    is_taken = validate_value record, value

    if is_taken
      message = options[:message] ||
        I18n.t('activerecord.errors.messages.taken')
      record.errors.add attribute, message
    end

    if Moderations::Banhammer.instance.abusive? value
      message = options[:message] ||
        I18n.t('activerecord.errors.messages.abusive')
      record.errors.add attribute, message
    end
  end

private

  def validate_value record, value
    value.match?(FORBIDDEN_NAMES) ||
      presence(record, value, Club, :name) ||
      presence(record, value, User, :nickname)
  end

  def presence record, value, klass, field
    query = record.is_a?(klass) ? klass.where.not(id: record.id) : klass

    query
      .where(
        "#{postgres_word_normalizer field} = #{postgres_word_normalizer '?'}",
        value
      )
      .any?
  end

  def postgres_word_normalizer text
    <<~SQL.squish
      translate(
        lower(unaccent(#{text})),
        'абвгдеёзийклмнопрстуфхцьіο0',
        'abvgdeezijklmnoprstufxc`ioo'
      )
    SQL
  end
end
