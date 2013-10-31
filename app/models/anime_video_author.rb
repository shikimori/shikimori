class AnimeVideoAuthor < ActiveRecord::Base
  has_many :anime_videos

  attr_accessible :name

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
