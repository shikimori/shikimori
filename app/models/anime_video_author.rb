class AnimeVideoAuthor < ActiveRecord::Base
  has_many :anime_videos, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
