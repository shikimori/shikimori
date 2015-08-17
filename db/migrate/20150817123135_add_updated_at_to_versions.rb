class AddUpdatedAtToVersions < ActiveRecord::Migration
  def up
    add_column :versions, :updated_at, :datetime
    Version.connection.execute("update versions set updated_at=created_at")
  end

  def down
    remove_column :versions, :updated_at
  end
end
