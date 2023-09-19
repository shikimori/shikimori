class GenreV2 < ApplicationRecord
  validates :name, :russian, :mal_id,
    presence: true

  enumerize :entry_type,
    in: Types::GenreV2::EntryType.values
  enumerize :kind,
    in: Types::GenreV2::Kind.values,
    predicates: true

  boolean_attribute :active
  boolean_attribute :censored

  DOUJINSHI_IDS = [61]

  EROTICA_IDS = [539, 540]
  HENTAI_IDS = [17, 59] # + DOUJINSHI_IDS
  # YAOI_IDS = [33, 65]
  # YURI_IDS = [34, 75]

  CENSORED_IDS = EROTICA_IDS + HENTAI_IDS # + YAOI_IDS + YURI_IDS

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
