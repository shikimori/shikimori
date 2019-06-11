class RemoveIsUnknownAndIsTorrentFromEpisodesNotification < ActiveRecord::Migration[5.2]
  def change
    remove_column :episode_notifications, :is_unknown, :boolean, null: false, default: false
    remove_column :episode_notifications, :is_torrent, :boolean, null: false, default: false
  end
end
