class MigrateEntryViewToNewSchema < ActiveRecord::Migration
  def self.up
    drop_table :entry_views
    create_table :entry_views, :id => false do |t|
      t.integer :user_id
      t.integer :entry_id
    end
    add_index :entry_views, [:user_id, :entry_id]
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
