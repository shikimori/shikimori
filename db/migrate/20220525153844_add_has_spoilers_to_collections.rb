class AddHasSpoilersToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :has_spoilers, :boolean
  end
end
