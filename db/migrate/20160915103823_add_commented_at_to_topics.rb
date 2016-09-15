class AddCommentedAtToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :commented_at, :datetime
  end
end
