class CreateCollectionLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :collection_links do |t|
      t.references :collection, null: false
      t.references :linked, polymorphic: true, null: false
      t.string :group

      t.timestamps
    end
  end
end
