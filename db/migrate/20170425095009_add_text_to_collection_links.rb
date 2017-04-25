class AddTextToCollectionLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :collection_links, :text, :string, limit: 2048
  end
end
