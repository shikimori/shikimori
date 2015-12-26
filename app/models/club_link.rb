class ClubLink < ActiveRecord::Base
  belongs_to :club, touch: true
  belongs_to :linked, polymorphic: true
end
