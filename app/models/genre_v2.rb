class GenreV2 < ApplicationRecord
  validates :name, :russian, :mal_id,
    presence: true

  enumerize :entry_type,
    in: Types::Genre::EntryType.values
  enumerize :kind,
    in: Types::Genre::Kind.values,
    predicates: true

  boolean_attribute :active

  def to_param
    "#{id}-#{english.tr ' ', '-'}"
  end

  def anime?
    entry_type == Types::Genre::EntryType['Anime']
  end

  def manga?
    entry_type == Types::Genre::EntryType['Manga']
  end
end
