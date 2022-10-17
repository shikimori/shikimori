class AnimeStatHistory < ApplicationRecord
  belongs_to :anime, optional: true
  belongs_to :manga, optional: true
end
