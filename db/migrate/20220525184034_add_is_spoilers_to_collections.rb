class AddIsSpoilersToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :is_spoilers, :boolean, null: false, default: false
  end
end
