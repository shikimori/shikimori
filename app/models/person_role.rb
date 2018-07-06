class PersonRole < ApplicationRecord
  belongs_to :anime, touch: true
  belongs_to :manga, touch: true
  belongs_to :character, touch: true
  belongs_to :person, touch: true

  DIRECTOR_ROLES = [
    'Director',
    'Co-Director',
    'Original Creator',
    'Story & Art',
    'Story, Art'
  ]

  scope :main, -> { where(roles: %w[Main]).where.not(character_id: 0) }
  scope :supporting, -> { where.not(roles: %w[Main], character_id: 0) }

  scope :people, -> {
    includes(:person).where.not(person_id: 0, people: { name: '' })
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
