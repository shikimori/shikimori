class RemoveUnusedIndexesV2 < ActiveRecord::Migration[5.2]
  def change
    remove_index :anime_videos, name: 'index_anime_videos_on_url'
    remove_index :anime_video_reports, name: 'index_anime_video_reports_on_state_and_updated_at'
    remove_index :anime_video_reports, name: 'index_anime_video_reports_on_kind'
    remove_index :users, name: 'index_users_on_style_id'
    remove_index :anime_video_authors, name: 'index_anime_video_authors_on_name'
  end
end
