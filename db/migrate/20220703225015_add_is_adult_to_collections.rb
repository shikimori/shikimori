class AddIsAdultToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :is_adult, :boolean, null: false, default: false
  end
end
