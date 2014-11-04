class AddMessageToAnimeVideoReport < ActiveRecord::Migration
  def change
    add_column :anime_video_reports, :message, :string, limit: 1000
  end
end
