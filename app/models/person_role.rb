class PersonRole < ActiveRecord::Base
  belongs_to :anime
  belongs_to :manga
  belongs_to :character
  belongs_to :person

  scope :main, -> {
    where(role: 'Main')
      .where.not(character_id: 0)
  }
  scope :supporting, -> { where.not(role: 'Main', character_id: 0) }

  scope :people, -> {
    includes(:person)
      .where.not(person_id: 0, people: { name: '' })
  }
  scope :directors, -> {
    people.
      where "role ilike '%Director%' or role ilike '%Original Creator%' or role ilike '%Story & Art%' or role ilike '%Story%' or role ilike '%Art%'"
  }
end
