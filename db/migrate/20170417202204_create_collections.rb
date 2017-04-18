class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.string :name, null: false
      t.references :user, null: false
      t.string :kind, null: false
      t.text :text, null: false
      t.string :locale, null: false

      t.timestamps
    end
  end
end
