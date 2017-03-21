class ClubLink < ApplicationRecord
  belongs_to :club, touch: true
  belongs_to :linked, polymorphic: true, touch: true
end
