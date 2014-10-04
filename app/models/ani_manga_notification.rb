class AniMangaNotification < ActiveRecord::Base
  validates :item_id, :item_type, presence: true

  def self.video_episode anime_video
    AniMangaNotification.create! item_id: anime_video.id, item_type: AnimeVideo.name
  end
end
