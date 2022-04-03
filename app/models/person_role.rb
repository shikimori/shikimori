class PersonRole < ApplicationRecord
  belongs_to :anime, touch: true, optional: true
  belongs_to :manga, touch: true, optional: true
  belongs_to :character, touch: true, optional: true
  belongs_to :person, touch: true, optional: true

  DIRECTOR_ROLES = [
    'Chief Producer',
    'Co-Director',
    'Director',
    'Original Creator',
    'Story & Art',
    'Story',
    'Art'
  ]

  scope :main, -> {
    where(roles: %w[Main])
      .where.not(character_id: 0)
  }
  scope :supporting, -> {
    where.not(roles: %w[Main])
      .where.not(character_id: 0)
  }
  scope :people, -> {
    includes(:person)
      .where.not(person_id: 0)
      .where.not(people: { name: '' })
  }
  scope :directors, -> {
    people.where(
      <<-SQL
        roles && '{#{DIRECTOR_ROLES.join ','}}'::text[]
      SQL
    )
  }

  def entry
    anime || manga
  end
end
