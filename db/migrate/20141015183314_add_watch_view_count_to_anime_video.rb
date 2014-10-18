class AddWatchViewCountToAnimeVideo < ActiveRecord::Migration
  def change
    add_column :anime_videos, :watch_view_count, :integer
  end
end
