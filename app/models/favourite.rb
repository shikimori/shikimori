class Favourite < ApplicationRecord
  belongs_to :linked, polymorphic: true, touch: true
  belongs_to :user, touch: true

  Seyu = 'seyu'
  Mangaka = 'mangaka'
  Producer = 'producer'
  Person = 'person'

  LIMITS = {
    character: 18,
    anime: 7,
    manga: 7,
    ranobe: 7,
    person: 9
  }
end
