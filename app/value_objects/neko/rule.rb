class Neko::Rule
  include ShallowAttributes

  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Integer
  attribute :image, String, allow_nil: true
  attribute :border_color, String, allow_nil: true
  attribute :title_ru, String, allow_nil: true
  attribute :text_ru, String, allow_nil: true
  attribute :title_en, String, allow_nil: true
  attribute :text_en, String, allow_nil: true
  attribute :topic_id, Integer
  attribute :rule, Hash

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
    (%<table_name>s.status = 'released' and %<table_name>s.episodes >= :episodes) or (
      %<table_name>s.status != 'released' and (
        (%<table_name>s.episodes_aired != 0 and %<table_name>s.episodes_aired >= :episodes) or
        (%<table_name>s.episodes_aired = 0 and %<table_name>s.episodes >= :episodes)
      )
    )
  SQL

  CACHE_VERSION = :v4
  CLOUDFLARE_CACHING_FIX = "?#{CACHE_VERSION}"

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

  def author?
    group == Types::Achievement::NekoGroup[:author]
  end

  def group_name
    I18n.t "achievements.group.#{group}"
  end

  def title user, is_ru_host # rubocop:disable PerceivedComplexity, CyclomaticComplexity
    send("title_#{franchise? ? locale_key(user) : I18n.locale}") ||
      (neko_id.to_s.titleize if franchise? || author?) ||
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

  def hint user, is_ru_host
    if franchise? || author?
      title user, is_ru_host
    else
      I18n.t "achievements.hint.#{neko_id}",
        threshold: rule[:threshold],
        default: proc { default_hint }
    end
  end

  def neko_name
    I18n.t "achievements.neko_name.#{neko_id}",
      default: franchise? || author? ? neko_id.to_s.titleize : neko_id.to_s.capitalize
  end

  def progress
    0
  end

  def image
    "#{images.first}#{CLOUDFLARE_CACHING_FIX}" if images.first.present?
  end

  def border_color
    border_colors.first
  end

  def images
    Array(attributes[:image]&.split(',') || [nil]).map do |image_path|
      "#{image_path}#{CLOUDFLARE_CACHING_FIX}" if image_path
    end
  end

  def border_colors
    Array(attributes[:border_color]&.split(',') || [])
  end

  def sort_criteria
    [Types::Achievement::ORDERED_NEKO_IDS.index(neko_id), level]
  end

  def animes_count
    return if rule[:filters].blank?

    animes_scope.size
  end

  def animes_scope filters = rule[:filters]
    scope = Animes::NekoScope.call
    return scope unless filters

    if filters['anime_ids']
      scope.where! id: filters['anime_ids']
    end

    if filters['not_anime_ids']
      scope = scope.where.not id: filters['not_anime_ids']
    end

    if filters['genre_ids']
      grenre_ids = filters['genre_ids'].map(&:to_i).join(',')
      scope.where! "genre_ids && '{#{grenre_ids}}' and kind != 'Special'"
    end

    if filters['episodes_gte']
      scope.where!(
        format(EPISODES_GTE_SQL, table_name: scope.table_name),
        episodes: filters['episodes_gte'].to_i
      )
    end

    if filters['duration_lte']
      duration_lte = filters['duration_lte'].to_i
      scope.where! 'duration <= ?', duration_lte
    end

    if filters['year_lte']
      year_lte = filters['year_lte'].to_i
      scope.where! 'aired_on <= ?', Date.new(year_lte).end_of_year
    end

    if filters['franchise']
      scope.where! franchise: filters['franchise']
    end

    if filters['or']
      scope.or animes_scope(filters['or'])
    else
      scope
    end
  end

  def statistics
    @statistics ||= Achievements::Statistics.call neko_id, level
  end

  def cache_key
    [
      Digest::MD5.hexdigest(to_json),
      Achievement.where(neko_id: neko_id).cache_key,
      CACHE_VERSION
    ]
  end

  def threshold_percent?
    rule[:threshold].is_a?(String) && rule[:threshold].match?(/^\d+%$/)
  end

  def threshold_percent animes_count
    if threshold_percent?
      rule[:threshold].to_f
    else
      (rule[:threshold].to_f * 100.0 / animes_count).ceil(2)
    end
  end

  def threshold_value animes_count
    if threshold_percent?
      (animes_count / 100.0 * rule[:threshold].to_f).ceil
    else
      rule[:threshold].to_i
    end
  end

  def franchise_percent user # rubocop:disable AbcSize
    return 0 unless user

    animes = animes_scope.to_a

    user_time = anime_rates(user, true)
      .where(target_id: animes.map(&:id))
      .sum do |user_rate|
        anime = animes.find { |v| v.id == user_rate.target_id }

        user_rate.watching? || user_rate.on_hold? ?
          anime.duration * user_rate.episodes :
          Neko::Duration.call(anime)
      end

    franchise_time = animes_scope.sum { |anime| Neko::Duration.call anime }

    (user_time * 100.0 / franchise_time).floor(2)
  end

  def overall_percent user, animes_count
    return 0 unless user && animes_count

    scope = anime_rates(user, false).where(target_id: animes_scope)

    (scope.count * 100.0 / animes_count).floor(2)
  end

  def anime_rates user, is_add_watching
    return UserRate.none unless user

    statuses =
      if is_add_watching
        %i[completed rewatching watching on_hold]
      else
        %i[completed rewatching]
      end

    user.anime_rates.where(status: statuses)
  end

private

  def default_hint
    I18n.t 'achievements.hint.default',
      neko_name: neko_name,
      level: level
  end

  def locale_key user
    if Localization::RussianNamesPolicy.call(user)
      :ru
    else
      :en
    end
  end
end
