class AnimeVideoAuthor < ActiveRecord::Base
  has_many :anime_videos, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
end
