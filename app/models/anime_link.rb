class AnimeLink < ApplicationRecord
  belongs_to :anime, touch: true

  enumerize :service,
    in: %i[findanime hentaianime animespirit],
    predicates: true

  validates :anime, presence: true
  validates :service, presence: true
  validates :identifier,
    presence: true,
    uniqueness: { scope: %i[service anime_id] }
end
