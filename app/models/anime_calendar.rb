class AnimeCalendar < ActiveRecord::Base
  belongs_to :anime

  validates :anime, :episode, :start_at, presence: true
end
