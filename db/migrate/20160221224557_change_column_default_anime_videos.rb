class ChangeColumnDefaultAnimeVideos < ActiveRecord::Migration
  def change
    change_column_default :anime_videos, :quality, nil
    AnimeVideo.where(quality: nil).update_all quality: :unknown
    AnimeVideo.where(language: nil).update_all language: :unknown
  end
end
