class Genre < ApplicationRecord
  include Translation

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 4096 }

  enumerize :kind, in: %i[anime manga], predicates: true

  DOUJINSHI_IDS = [61]

  EROTICA_IDS = [539, 540]
  HENTAI_IDS = [12, 59] # + DOUJINSHI_IDS
  YAOI_IDS = [33, 65]
  YURI_IDS = [34, 75]

  SHOUNEN_AI_IDS = [28, 55]
  SHOUJO_AI_IDS = [26, 73]

  BANNED_IDS = YAOI_IDS + YURI_IDS
  AI_IDS = SHOUJO_AI_IDS + SHOUNEN_AI_IDS

  CENSORED_IDS = EROTICA_IDS + HENTAI_IDS + BANNED_IDS + AI_IDS

  MAIN_GENRES = [
    'Seinen',
    'Josei',
    'Yaoi',
    'Hentai',
    'Action',
    'Comedy',
    'Drama',
    'Romance',
    'Slice of Life',
    'School',
    'Samurai',
    'Vampire',
    'Sci-Fi',
    'Mystery',
    'Mecha',
    'Yuri',
    'Shoujo Ai',
    'Shounen Ai',
    'Shoujo',
    'Shounen'
  ]

  LONG_NAME_GENRES = [
    'Slice of Life',
    'Martial Arts',
    'Supernatural',
    'Psychological'
  ]

  MERGED = {}

  def main?
    MAIN_GENRES.include?(english)
  end

  def title ru_case: :subjective, user: nil
    raise ArgumentError, "ru_case: #{ru_case}" unless ru_case == :subjective

    key = english.parameterize.underscore
    name = UsersHelper.localized_name self, user
    kind = self.kind.capitalize.constantize.model_name.human

    i18n_t(
      "title.#{ru_case}.#{self.kind}.#{key}",
      localized_entry_type: kind,
      default: i18n_t('default_title', localized_entry_type: kind, name:)
    ).capitalize
  end

  def english
    self[:name]
  end

  def to_param
    "#{id}-#{english.tr ' ', '-'}"
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
end
