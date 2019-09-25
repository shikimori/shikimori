class Favourite < ApplicationRecord
  belongs_to :linked, polymorphic: true, touch: true
  belongs_to :user, touch: true

  enumerize :kind, in: Types::Favourite::Kinds.values
  enumerize :linked_type, in: Types::Favourite::LinkedTypes.values

  validates :kind,
    presence: true,
    if: -> { linked_type == Types::Favourite::LinkedTypes['Person'] }

  LIMITS = {
    Types::Favourite::LinkedTypes['Character'] => 18,
    Types::Favourite::LinkedTypes['Anime'] => 7,
    Types::Favourite::LinkedTypes['Manga'] => 7,
    Types::Favourite::LinkedTypes['Ranobe'] => 7,
    Types::Favourite::LinkedTypes['Person'] => 9
  }
end
