class AddPublishedAtToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :published_at, :datetime
  end
end
