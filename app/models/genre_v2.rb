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

  EROTICA_IDS = [539, 540]
  HENTAI_IDS = [12, 59]
  YAOI_IDS = [193, 195]
  YURI_IDS = [194, 196]

  SHOUNEN_AI_IDS = [133, 165]
  SHOUJO_AI_IDS = [129, 170]

  BANNED_IDS = YAOI_IDS + YURI_IDS
  AI_IDS = SHOUJO_AI_IDS + SHOUNEN_AI_IDS

  CENSORED_IDS = EROTICA_IDS + HENTAI_IDS + BANNED_IDS + AI_IDS

  def to_param
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

  def title ru_case: :subjective, user: nil
    key = name.parameterize.underscore
    name = UsersHelper.localized_name self, user
    entry_type = self.entry_type.constantize.model_name.human

    i18n_t(
      "title.#{ru_case}.#{self.entry_type}.#{key}",
      localized_entry_type: entry_type,
      default: i18n_t('default_title', localized_entry_type: entry_type, name:)
    ).capitalize
  end
end
