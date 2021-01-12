class AddTagsToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :tags, :text, default: [], null: false, array: true
  end
end
