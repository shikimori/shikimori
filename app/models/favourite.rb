class Favourite < ApplicationRecord
  acts_as_list scope: %i[user_id linked_type kind]

  belongs_to :linked, polymorphic: true
  belongs_to :user, touch: true

  enumerize :kind,
    in: Types::Favourite::Kind.values,
    predicates: true
  enumerize :linked_type, in: Types::Favourite::LinkedType.values

  scope :ordered, -> { order :position }

  # kind cannot be blank, otherwise acts_as_list ordering wont work properly
  validates :kind, presence: true

  validates :user_id,
    uniqueness: { scope: %i[linked_id linked_type kind] },
    if: -> { kind.present? }

  validates :user_id,
    uniqueness: { scope: %i[linked_id linked_type] },
    if: -> { kind.blank? }

  LIMITS = {
    Types::Favourite::LinkedType['Character'] => 144,
    Types::Favourite::LinkedType['Anime'] => 144,
    Types::Favourite::LinkedType['Manga'] => 144,
    Types::Favourite::LinkedType['Ranobe'] => 144,
    Types::Favourite::LinkedType['Person'] => 144
  }
end
