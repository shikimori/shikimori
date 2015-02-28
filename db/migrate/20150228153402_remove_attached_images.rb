class RemoveAttachedImages < ActiveRecord::Migration
  def up
    drop_table :attached_images
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
