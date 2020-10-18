class AddSuggestedIndexesV4 < ActiveRecord::Migration[5.2]
  def change
    commit_db_transaction
    add_index :messages, [:to_id, :linked_id], algorithm: :concurrently
    add_index :votes, [:voter_id, :votable_id], algorithm: :concurrently
  end
end
