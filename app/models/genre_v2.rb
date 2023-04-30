class GenreV2 < ApplicationRecord
  validates :name, :russian, :mal_id,
    presence: true

  enumerize :kind,
    in: Types::GenreV2::Kind.values,
    predicates: true

  boolean_attribute :active
  boolean_attribute :censored

  def to_param
    "#{id}-#{name.tr ' ', '-'}"
  end
end
