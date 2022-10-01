class RemoveAllEnTopics < ActiveRecord::Migration[6.1]
  def up
    scope = Topic.where(locale: 'en')
    scope.where('comments_count = 0').delete_all
    scope.destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
