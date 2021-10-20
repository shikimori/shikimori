class RemoveMessagesUpdatedAt < ActiveRecord::Migration[5.2]
  def up
    remove_column :messages, :updated_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
