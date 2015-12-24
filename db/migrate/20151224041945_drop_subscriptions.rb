class DropSubscriptions < ActiveRecord::Migration
  def up
    drop_table :subscriptions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
