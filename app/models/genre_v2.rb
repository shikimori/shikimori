class GenreV2 < ApplicationRecord
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
  YAOI_IDS = [195, 197]
  YURI_IDS = [196, 198]

  SHOUNEN_AI_IDS = [133, 165]
  SHOUJO_AI_IDS = [129, 170]

  BANNED_IDS = YAOI_IDS + YURI_IDS
  PROBABLY_BANNED_IDS = SHOUJO_AI_IDS + SHOUNEN_AI_IDS

  CENSORED_IDS = EROTICA_IDS + HENTAI_IDS + BANNED_IDS + PROBABLY_BANNED_IDS

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

  def probably_banned?
    id.in? PROBABLY_BANNED_IDS
  end
end
