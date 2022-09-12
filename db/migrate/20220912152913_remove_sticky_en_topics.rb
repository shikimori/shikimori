class RemoveStickyEnTopics < ActiveRecord::Migration[6.1]
  def up
    Topic.where(id: [210_000, 220_000, 230_000, 240_000, 250_000]).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
