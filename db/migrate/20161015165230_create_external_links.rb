class CreateExternalLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :external_links do |t|
      t.references :entry, polymorphic: true, null: false, index: true
      t.string :source, null: false
      t.string :url, null: false
      t.timestamps null: false
    end
  end
end
