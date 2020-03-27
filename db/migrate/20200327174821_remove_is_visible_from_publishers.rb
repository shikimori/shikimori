class RemoveIsVisibleFromPublishers < ActiveRecord::Migration[5.2]
  def change
    remove_column :publishers, :is_visible, :boolean
  end
end
