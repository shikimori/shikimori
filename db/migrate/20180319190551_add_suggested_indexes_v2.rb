class AddSuggestedIndexesV2 < ActiveRecord::Migration[5.1]
  def change
    commit_db_transaction
    add_index :anime_video_reports, [:kind], algorithm: :concurrently
    add_index :user_tokens, [:uid], algorithm: :concurrently
  end
end
