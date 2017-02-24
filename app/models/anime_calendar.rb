class AnimeCalendar < ActiveRecord::Base
  belongs_to :anime, touch: true

  validates :anime, :episode, :start_at, presence: true
end
