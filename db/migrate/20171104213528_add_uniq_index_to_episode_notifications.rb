class AddUniqIndexToEpisodeNotifications < ActiveRecord::Migration[5.1]
  def change
    add_index :episode_notifications, %i[anime_id episode], unique: true
  end
end
