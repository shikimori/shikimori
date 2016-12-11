class AnimeLink < ActiveRecord::Base
  belongs_to :anime, touch: true

  enumerize :service, in: [:findanime, :hentaianime, :animespirit], predicates: true

  validates :anime, presence: true
  validates :service, presence: true
  validates :identifier, presence: true, uniqueness: { scope: [:service, :anime_id] }
end
