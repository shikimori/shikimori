class RemoveObsoleteUserFields < ActiveRecord::Migration
  def up
    remove_column :users, :icq
    remove_column :users, :jabber
    remove_column :users, :skype
    remove_column :users, :mail
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
