class CreateReviewViews < ActiveRecord::Migration
  def self.up
    create_table :review_views, :id => false do |t|
      t.integer :user_id
      t.integer :review_id
    end
    add_index :review_views, [:user_id, :review_id]
  end

  def self.down
    drop_table :review_views
  end
end
