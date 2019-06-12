class AddIsAnime365ToEpisodeNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :episode_notifications, :is_anime365, :boolean, default: false, null: false
  end
end
