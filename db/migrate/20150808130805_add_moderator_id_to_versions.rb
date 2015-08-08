class AddModeratorIdToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :moderator_id, :integer
    add_index :versions, :moderator_id
  end
end
