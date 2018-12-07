class CleanupAnimediaVideos < ActiveRecord::Migration[5.2]
  def up
    AnimeVideo.where("url like '%animedia%'").find_each do |anime_video|
      anime_video.url = anime_video.url
      anime_video.save! if anime_video.changed?
    rescue ActiveRecord::RecordInvalid
      anime_video.destroy!
    end
  end
end
