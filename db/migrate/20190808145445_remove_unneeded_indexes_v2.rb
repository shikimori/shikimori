class RemoveUnneededIndexesV2 < ActiveRecord::Migration[5.2]
  def change
    remove_index :achievements, name: "index_achievements_on_user_id"
    remove_index :comments, name: "index_comments_on_user_id"
    remove_index :episode_notifications, name: "index_episode_notifications_on_anime_id"
    remove_index :user_histories, name: "i_user_target"
  end
end
