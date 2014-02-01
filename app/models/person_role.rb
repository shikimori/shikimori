class PersonRole < ActiveRecord::Base
  belongs_to :anime
  belongs_to :manga
  belongs_to :character
  belongs_to :person

  scope :main, -> { where { role.eq('Main') & character_id.not_eq(0) } }
  scope :people, -> { where { person_id.not_eq(0) & people.name.not_eq('') }.includes(:person) }
  scope :directors, -> { people.where { role.like('%Director%') | role.like('%Original Creator%') | role.like('%Story & Art%') | role.like('%Story%') | role.like('%Art%') } }
end
