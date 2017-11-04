class AddIsTorrentToEpisodeNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :episode_notifications, :is_torrent, :boolean,
      default: false,
      null: false
  end
end
