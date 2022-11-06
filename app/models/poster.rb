class Poster < ApplicationRecord
  belongs_to :anime, optional: true
  belongs_to :manga, optional: true
  belongs_to :character, optional: true
  belongs_to :person, optional: true
end
