class AddCommentIdToReview < ActiveRecord::Migration
  def self.up
    add_column :reviews, :comment_id, :integer
  end

  def self.down
    remove_column :reviews, :comment_id
  end
end
