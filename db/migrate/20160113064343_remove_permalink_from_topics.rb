class RemovePermalinkFromTopics < ActiveRecord::Migration
  def up
    remove_column :entries, :permalink
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
