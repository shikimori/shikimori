class AddIsPinnedToTopics < ActiveRecord::Migration[5.2]
  def change
    add_column :topics, :is_pinned, :boolean,
      null: false,
      default: false
    add_index :topics, %i[is_pinned], where: 'is_pinned = true'
  end
end
