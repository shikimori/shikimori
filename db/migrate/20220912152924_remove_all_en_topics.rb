class RemoveAllEnTopics < ActiveRecord::Migration[6.1]
  def up
    Topic.where(locale: 'en').destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
