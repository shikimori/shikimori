class AddTagsForTopics < ActiveRecord::Migration[5.2]
  def change
    add_column :topics, :tags, :text, null: false, default: [], array: true
    add_index :topics, :tags, using: :gin
  end
end
