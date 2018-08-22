class ContestWinner < ApplicationRecord
  belongs_to :contest

  belongs_to :item, polymorphic: true, touch: true
  belongs_to :anime, foreign_key: :item_id, optional: true
  belongs_to :character, foreign_key: :item_id, optional: true

  validates :contest, :item, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }
end
