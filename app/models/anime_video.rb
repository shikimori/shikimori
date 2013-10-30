class AnimeVideo < ActiveRecord::Base
  belongs_to :anime
  belongs_to :author,
    class_name: AnimeVideoAuthor.name,
    foreign_key: :anime_video_author_id
  attr_accessible :episode, :kind, :url
end
