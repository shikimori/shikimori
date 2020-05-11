class ClubLink < ApplicationRecord
  belongs_to :club, touch: true
  belongs_to :linked, polymorphic: true, touch: true

  validates :club_id, uniqueness: { scope: %i[linked_id linked_type] }
end
