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
  attribute :generator, Types::Hash

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
    rule: {},
    generator: {}
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

  def title show_blank = false
    show_blank ? maybe_title : mandatory_title
  end

  def text show_blank = false
    if show_blank
      send("text_#{I18n.locale}")
    else
      send("text_#{I18n.locale}") ||
        text_ru ||
        (NO_RULE.text if self != NO_RULE)
    end
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
    @animes_count ||= begin
      return if rule[:filters].blank?
      return rule[:filters]['anime_ids'].size if rule[:filters]['anime_ids']

      animes_scope.size
    end
  end

  def animes_scope
    scope = Animes::NekoScope.call
    return scope unless rule[:filters]

    scope.where! id: rule[:filters]['anime_ids'] if rule[:filters]['anime_ids']

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

  def spent_time user # rubocop:disable AbcSize
    animes = animes_scope.to_a

    user_time = user
      .anime_rates
      .where(target_id: animes.map(&:id))
      .where(status: %i[completed rewatching watching])
      .sum do |user_rate|
        anime = animes.find { |v| v.id == user_rate.target_id }

        user_rate.watching? ?
          anime.duration * user_rate.episodes :
          Neko::Duration.call(anime)
      end

    franchise_time = animes_scope.sum { |anime| Neko::Duration.call anime }

    "#{(user_time * 100.0 / franchise_time).floor(2)}%".gsub(/\0%/, '%')
  end

private

  def mandatory_title
    maybe_title ||
      title_ru ||
      (neko_id if franchise?) ||
      (NO_RULE.title if self != NO_RULE)
  end

  def maybe_title
    send("title_#{I18n.locale}")
  end

  def default_hint
    I18n.t 'achievements.hint.default',
      neko_name: neko_name,
      level: level
  end
end
