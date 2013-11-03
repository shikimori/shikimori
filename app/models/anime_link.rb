class AnimeLink < ActiveRecord::Base
  extend Enumerize
  belongs_to :anime, touch: true

  enumerize :service, in: [:findanime], predicates: true

  validates :anime, presence: true
  validates :service, presence: true
  validates :identifier, presence: true#, uniqueness: { scope: [:service, :anime_id] }
end
