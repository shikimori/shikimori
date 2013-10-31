class AnimeVideo < ActiveRecord::Base
  extend Enumerize

  belongs_to :anime

  belongs_to :author,
    class_name: AnimeVideoAuthor.name,
    foreign_key: :anime_video_author_id

  attr_accessible :episode, :kind, :url

  enumerize :kind, in: [:subtitles, :dubbed], predicates: true

  validates :anime, presence: true
  validates :url, presence: true
end
