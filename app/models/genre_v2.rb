class GenreV2 < ApplicationRecord
  validates :name, :russian, presence: true

  enumerize :entry_type,
    in: Types::GenreV2::EntryType.values
  enumerize :kind,
    in: Types::GenreV2::Kind.values,
    predicates: true

  boolean_attribute :active
  boolean_attribute :censored

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
