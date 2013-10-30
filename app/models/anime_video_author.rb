class AnimeVideoAuthor < ActiveRecord::Base
  has_many :anime_videos

  attr_accessible :name
end
