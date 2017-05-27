class Achievement < ApplicationRecord
  belongs_to :user

  validates :user, :neko_id, :level, :progress, presence: true

  enumerize :neko_id,
    in: Types::Achievement::NekoId.values,
    predicates: { prefix: true }
end
