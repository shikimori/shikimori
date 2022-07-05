class AddIsCensoredToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :is_censored, :boolean, null: false, default: false
  end
end
