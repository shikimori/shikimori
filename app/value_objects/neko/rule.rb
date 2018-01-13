class Neko::Rule < Dry::Struct
  constructor_type :strict

  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Types::Coercible::Int
  attribute :image, Types::String.optional
  attribute :border_color, Types::String.optional
  attribute :title_ru, Types::String.optional
  attribute :text_ru, Types::String.optional
  attribute :title_en, Types::String.optional
  attribute :text_en, Types::String.optional
  attribute :topic_id, Types::Coercible::Int.optional
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

  def title show_blank = false
    if show_blank
      send("title_#{I18n.locale}")
    else
      send("title_#{I18n.locale}") ||
        title_ru ||
        (NO_RULE.title if self != NO_RULE)
    end
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
    default: neko_id.to_s.capitalize
  end

  def progress
    0
  end

  def image
    @image.is_a?(Array) ? @image.first : @image
  end

  def border_color
    @border_color.is_a?(Array) ? @border_color.first : @border_color
  end

  def images
    Array(@image)
  end

  def border_colors
    Array(@border_color)
  end

  def sort_criteria
    [Types::Achievement::NEKO_IDS.index(neko_id), level]
  end

  # rubocop:disable AbcSize
  def animes_count
    @animes_count ||= begin
      return if rule[:filters].blank?
      return rule[:filters]['anime_ids'].size if rule[:filters]['anime_ids']

      scope = Anime.all

      if rule[:filters]['genre_ids']
        grenre_ids = rule[:filters]['genre_ids'].map(&:to_i).join(',')
        scope.where! "genre_ids && '{#{grenre_ids}}' and kind != 'Special'"
      end

      scope.size
    end
  end
  # rubocop:enable AbcSize

private

  def default_hint
    I18n.t 'achievements.hint.default',
      neko_name: neko_name,
      level: level
  end
end
