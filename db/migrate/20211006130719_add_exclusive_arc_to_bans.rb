class AddExclusiveArcToBans < ActiveRecord::Migration[5.2]
  def change
    add_column :bans, :topic_id, :integer
    add_column :bans, :review_id, :integer

    add_index :bans, :topic_id
    add_index :bans, :review_id
    add_index :bans, :comment_id
  end
end
