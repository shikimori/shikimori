class AddSuggestedIndexes < ActiveRecord::Migration[5.1]
  def change
    commit_db_transaction
    add_index :anime_video_reports, [:state, :updated_at], algorithm: :concurrently
    add_index :anime_videos, [:url], algorithm: :concurrently
    add_index :characters, [:russian], algorithm: :concurrently
    add_index :comments, [:user_id, :id], algorithm: :concurrently
    add_index :messages, [:from_id, :id], algorithm: :concurrently
    add_index :users, [:email], algorithm: :concurrently
    add_index :users, [:remember_token], algorithm: :concurrently
  end
end
