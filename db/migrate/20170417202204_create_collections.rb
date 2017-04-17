class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.string :name, null: false
      t.references :user, null: false

      t.timestamps
    end
  end
end
