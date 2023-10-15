class GenreV2 < ApplicationRecord
  validates :name, :russian, presence: true

  enumerize :entry_type,
    in: Types::GenreV2::EntryType.values
  enumerize :kind,
    in: Types::GenreV2::Kind.values,
    predicates: true

  boolean_attribute :active
  boolean_attribute :censored

  SHOUNEN_AI_IDS = [133, 165]
  SHOUJO_AI_IDS = [129, 170]

  PROBABLY_BANNED_IDS = SHOUJO_AI_IDS + SHOUNEN_AI_IDS

  EROTICA_IDS = [539, 540]
  HENTAI_IDS = [12, 59]

  CENSORED_IDS = EROTICA_IDS + HENTAI_IDS + PROBABLY_BANNED_IDS

  def to_param
    "#{id}-#{name.tr ' ', '-'}"
  end

  def anime?
    entry_type == Types::GenreV2::EntryType['Anime']
  end

  def manga?
    entry_type == Types::GenreV2::EntryType['Manga']
  end
end
