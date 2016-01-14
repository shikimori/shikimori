class CleanupBodyAndTitleForGeneratedNews < ActiveRecord::Migration
  def up
    Topics::NewsTopic
      .where(generated: true)
      .update_all(title: nil, body: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
