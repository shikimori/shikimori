class GenreV2 < ApplicationRecord
  include Translation

  validates :name, :russian, presence: true

  enumerize :entry_type,
    in: Types::GenreV2::EntryType.values
  enumerize :kind,
    in: Types::GenreV2::Kind.values,
    predicates: true

  boolean_attribute :active
  boolean_attribute :censored

  EROTICA_IDS = [539, 601]
  HENTAI_IDS = [12, 602]
  YAOI_IDS = [33, 65]
  YURI_IDS = [34, 75]

  SHOUNEN_AI_IDS = [133, 165]
  SHOUJO_AI_IDS = [129, 170]

  BANNED_IDS = YAOI_IDS + YURI_IDS
  AI_IDS = SHOUJO_AI_IDS + SHOUNEN_AI_IDS

  CENSORED_IDS = EROTICA_IDS + HENTAI_IDS + BANNED_IDS + AI_IDS
  TEMPORARILY_POSTERS_DISABLED_IDS = [
    539, # Anime Erotica
    12, # Anime Hentai
    601, # Manga Erotica
    602 # Manga Hentai
  ]

  def to_param
    temporarily_posters_disabled? ?
      id.to_s :
      "#{id}-#{name.tr ' ', '-'}"
  end

  def anime?
    entry_type == Types::GenreV2::EntryType['Anime']
  end

  def manga?
    entry_type == Types::GenreV2::EntryType['Manga']
  end

  def censored?
    CENSORED_IDS.include? id
  end

  def banned?
    id.in? BANNED_IDS
  end

  def ai?
    id.in? AI_IDS
  end

  def temporarily_posters_disabled?
    id.in? TEMPORARILY_POSTERS_DISABLED_IDS
  end

  def title(
    ru_case: :subjective,
    entry_type: self.entry_type,
    user: nil
  )
    raise ArgumentError, "ru_case: #{ru_case}" unless ru_case == :subjective

    key = name.parameterize.underscore
    name = UsersHelper.localized_name self, user
    localized_entry_type = entry_type.constantize.model_name.human.downcase

    text = i18n_t(
      "title.#{ru_case}.#{entry_type.downcase}.#{key}",
      localized_entry_type:,
      default: i18n_t('default_title', localized_entry_type:, name:)
    )

    if text.starts_with? name
      text
    else
      text.downcase.capitalize
    end
  end
end
