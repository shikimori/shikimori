class Neko::Rule < Dry::Struct
  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Types::Coercible::Integer
  attribute :image, Types::String.optional
  attribute :border_color, Types::String.optional
  attribute :title_ru, Types::String.optional
  attribute :text_ru, Types::String.optional
  attribute :title_en, Types::String.optional
  attribute :text_en, Types::String.optional
  attribute :topic_id, Types::Coercible::Integer.optional
  attribute :rule, Types::Hash

  NO_RULE = new(
    neko_id: Types::Achievement::NekoId[:test],
    level: 0,
    image: nil,
    border_color: nil,
    title_ru: 'Нет названия',
    text_ru: 'Нет текста',
    title_en: 'No title',
    text_en: 'No text',
    topic_id: nil,
    rule: {}
  )

  EPISODES_GTE_SQL = <<~SQL.squish
    (status = 'released' and episodes >= :episodes) or (
      status != 'released' and (
        (episodes_aired != 0 and episodes_aired >= :episodes) or
        (episodes_aired = 0 and episodes >= :episodes)
      )
    )
  SQL

  def group
    Types::Achievement::INVERTED_NEKO_IDS[
      Types::Achievement::NekoId[neko_id]
    ]
  end

  def common?
    group == Types::Achievement::NekoGroup[:common]
  end

  def genre?
    group == Types::Achievement::NekoGroup[:genre]
  end

  def franchise?
    group == Types::Achievement::NekoGroup[:franchise]
  end

  def group_name
    I18n.t "achievements.group.#{group}"
  end

  def title user, is_ru_host # rubocop:disable PerceivedComplexity, CyclomaticComplexity
    send("title_#{franchise? ? locale_key(user) : I18n.locale}") ||
      (neko_id.to_s.titleize if franchise?) ||
      (title_ru if is_ru_host) ||
      (title_en unless is_ru_host) ||
      NO_RULE.title(user, is_ru_host)
  end

  def text is_ru_host
    send("text_#{I18n.locale}") ||
      (text_ru if is_ru_host) ||
      (text_en unless is_ru_host) ||
      NO_RULE.text(is_ru_host)
  end

  def hint
    I18n.t "achievements.hint.#{neko_id}",
      threshold: rule[:threshold],
      default: proc { default_hint }
  end

  def neko_name
    I18n.t "achievements.neko_name.#{neko_id}",
      default: franchise? ? neko_id.to_s.titleize : neko_id.to_s.capitalize
  end

  def progress
    0
  end

  def image
    images.first
  end

  def border_color
    border_colors.first
  end

  def images
    Array(attributes[:image]&.split(',') || [])
  end

  def border_colors
    Array(attributes[:border_color]&.split(',') || [])
  end

  def sort_criteria
    [Types::Achievement::ORDERED_NEKO_IDS.index(neko_id), level]
  end

  def animes_count
    return if rule[:filters].blank?
    return rule[:filters]['anime_ids'].size if rule[:filters]['anime_ids']

    animes_scope.size
  end

  def users_count
    Achievement.where(neko_id: neko_id, level: level).count
  end

  def users_scope
    User
      .where(id: Achievement.where(neko_id: neko_id, level: level).select(:user_id))
      .where.not("roles && '{#{Types::User::Roles[:cheat_bot]}}'")
      .order(:id)
  end

  def animes_scope
    scope = Animes::NekoScope.call
    return scope unless rule[:filters]

    if rule[:filters]['anime_ids']
      scope.where! id: rule[:filters]['anime_ids']
    end

    if rule[:filters]['not_anime_ids']
      scope = scope.where.not id: rule[:filters]['not_anime_ids']
    end

    if rule[:filters]['genre_ids']
      grenre_ids = rule[:filters]['genre_ids'].map(&:to_i).join(',')
      scope.where! "genre_ids && '{#{grenre_ids}}' and kind != 'Special'"
    end

    if rule[:filters]['episodes_gte']
      scope.where! EPISODES_GTE_SQL, episodes: rule[:filters]['episodes_gte'].to_i
    end

    if rule[:filters]['duration_lte']
      duration_lte = rule[:filters]['duration_lte'].to_i
      scope.where! 'duration <= ?', duration_lte
    end

    if rule[:filters]['year_lte']
      year_lte = rule[:filters]['year_lte'].to_i
      scope.where! 'aired_on <= ?', Date.new(year_lte).end_of_year
    end

    if rule[:filters]['franchise']
      scope.where! franchise: rule[:filters]['franchise']
    end

    scope
  end

  def statistics
    @statistics ||= Achievements::Statistics.call neko_id, level
  end

  def completed_percent user
    if rule[:filters]
      "#{franchise? ? franchise_percent(user) : common_percent(user)}%".gsub(/\0%/, '%')
    else
      common_amount user
    end
  end

  def cache_key
    [Digest::MD5.hexdigest(to_json), users_scope.cache_key]
  end

private

  def default_hint
    I18n.t 'achievements.hint.default',
      neko_name: neko_name,
      level: level
  end

  def franchise_percent user
    animes = animes_scope.to_a

    user_time = anime_rates(user, true)
      .where(target_id: animes.map(&:id))
      .sum do |user_rate|
        anime = animes.find { |v| v.id == user_rate.target_id }

        user_rate.watching? ?
          anime.duration * user_rate.episodes :
          Neko::Duration.call(anime)
      end

    franchise_time = animes_scope.sum { |anime| Neko::Duration.call anime }

    (user_time * 100.0 / franchise_time).floor(2)
  end

  def common_percent user
    scope = anime_rates(user, false).where(target_id: animes_scope)

    (scope.count * 100.0 / animes_count).floor(2)
  end

  def common_amount user
    anime_rates(user, false).count
  end

  def anime_rates user, is_add_watching
    statuses =
      if is_add_watching
        %i[completed rewatching watching]
      else
        %i[completed rewatching]
      end

    user.anime_rates.where(status: statuses)
  end

  def locale_key user
    if Localization::RussianNamesPolicy.call(user)
      :ru
    else
      :en
    end
  end
end
