class AddStateToCollections < ActiveRecord::Migration[5.0]
  def change
    add_column :collections, :state, :string, null: false
  end
end
