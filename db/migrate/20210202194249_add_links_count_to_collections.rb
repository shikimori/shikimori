class AddLinksCountToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :links_count, :integer, null: false, default: 0
  end
end
