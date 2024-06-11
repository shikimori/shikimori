class NameValidator < ActiveModel::EachValidator
  BANNED_NICKNAMES = %w[
    Youtoome
    shikimori
    shikimori.one
    shikimori.org
    shikimori.me
  ]
  PREDEFINED_PATHS = %i[
    about
    achievements
    anime-industry
    animes
    api
    bb_codes
    characters
    comments
    contests
    country
    csrf_token
    dashboards
    development
    facebook
    faye
    feedback
    for_right_holders
    forum
    hentai
    how_to_edit_achievements
    http_headers
    ignores
    imageboards
    info
    mangas
    messages
    moderations
    my_target_ad
    oauth
    oauth2
    oauth_request
    ongoings
    page404
    page503
    podcast
    polls
    privacy
    proxies
    proxy
    raise_exception
    ranobe
    redirect
    sitemap
    styles
    tableau
    topics
    terms
    tests
    timeout_120s
    twitter
    user_agent
    users
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
