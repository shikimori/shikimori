class RemoveIsVisibleFromForums < ActiveRecord::Migration[5.2]
  def change
    remove_column :forums, :is_visible, :boolean
  end
end
