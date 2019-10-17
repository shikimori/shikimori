class Favourite < ApplicationRecord
  acts_as_list scope: %i[user_id linked_type kind]

  belongs_to :linked, polymorphic: true, touch: true
  belongs_to :user, touch: true

  enumerize :kind,
    in: Types::Favourite::Kinds.values,
    predicates: true
  enumerize :linked_type, in: Types::Favourite::LinkedTypes.values

  scope :ordered, -> { order :position }

  validates :kind,
    presence: true,
    if: -> { linked_type == Types::Favourite::LinkedTypes['Person'] }

  validates :user_id,
    uniqueness: { scope: %i[linked_id linked_type kind] },
    if: -> { kind.present? }

  validates :user_id,
    uniqueness: { scope: %i[linked_id linked_type] },
    if: -> { kind.blank? }

  LIMITS = {
    Types::Favourite::LinkedTypes['Character'] => 144,
    Types::Favourite::LinkedTypes['Anime'] => 144,
    Types::Favourite::LinkedTypes['Manga'] => 144,
    Types::Favourite::LinkedTypes['Ranobe'] => 144,
    Types::Favourite::LinkedTypes['Person'] => 144
  }

  # kind cannot be nil, otherwise reordering in acts_as_list wont work as it is expected
  def kind=value
    if value.blank?
      attributes['kind'] = ''
    else
      super
    end
  end

  def kind
    super || ''
  end
end
