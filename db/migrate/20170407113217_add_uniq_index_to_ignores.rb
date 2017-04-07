class AddUniqIndexToIgnores < ActiveRecord::Migration[5.0]
  def change
    add_index :ignores, [:user_id, :target_id], unique: true
  end
end
