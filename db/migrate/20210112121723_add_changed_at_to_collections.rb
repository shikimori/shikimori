class AddChangedAtToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :changed_at, :datetime
  end
end
