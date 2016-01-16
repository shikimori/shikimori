class NullifyUpdatedAtForEmptyGeneratedNews < ActiveRecord::Migration
  def up
    Entry
      .where(generated: true, comments_count: 0, type: 'Topics::NewsTopic')
      .update_all(updated_at: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
