class CreateCollectionRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :collection_roles do |t|
      t.references :collection, foreign_key: true, null: false, index: true
      t.references :user, foreign_key: true, , null: false, index: true

      t.timestamps null: false
    end
  end
end
