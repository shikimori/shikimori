class AddIsVisibleToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :is_visible, :boolean
    Publisher.update_all is_visible: true
    change_column :publishers, :is_visible, :boolean, null: false
  end
end
