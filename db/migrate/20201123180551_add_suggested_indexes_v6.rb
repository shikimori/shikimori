class AddSuggestedIndexesV6 < ActiveRecord::Migration[5.2]
  def change
    commit_db_transaction
    add_index :animes, [:rating], algorithm: :concurrently
    add_index :topics, [:type, :forum_id], algorithm: :concurrently
    add_index :user_rate_logs, [:user_id, :id], algorithm: :concurrently
  end
end
