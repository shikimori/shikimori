class AddReviewToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :review, :boolean, default: false
  end

  def self.down
    remove_column :comments, :review
  end
end
