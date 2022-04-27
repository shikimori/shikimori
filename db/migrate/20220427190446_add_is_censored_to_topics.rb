class AddIsCensoredToTopics < ActiveRecord::Migration[6.1]
  def change
    add_column :topics, :is_censored, :boolean, null: false, default: false
  end
end
