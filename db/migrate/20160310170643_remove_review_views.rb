class RemoveReviewViews < ActiveRecord::Migration
  def up
    drop_table :review_views
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
