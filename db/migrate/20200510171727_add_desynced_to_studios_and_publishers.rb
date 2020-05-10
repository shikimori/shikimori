class AddDesyncedToStudiosAndPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :studios, :desynced, :text, default: [], null: false, array: true
    add_column :publishers, :desynced, :text, default: [], null: false, array: true
  end
end
