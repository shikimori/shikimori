class AddIsClosedToTopics < ActiveRecord::Migration[5.2]
  def change
    add_column :topics, :is_closed, :boolean, null: false, default: false
  end
end
