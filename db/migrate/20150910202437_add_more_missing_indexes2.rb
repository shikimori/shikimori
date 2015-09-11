class AddMoreMissingIndexes2 < ActiveRecord::Migration
  def change
    remove_index :comments, column: [:commentable_id, :commentable_type]
    add_index :friend_links, :src_id
    add_index :animes, [:status, :score, :kind], name: :anime_online_dashboard_query
  end
end
