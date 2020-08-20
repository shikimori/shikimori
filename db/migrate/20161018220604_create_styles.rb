class CreateStyles < ActiveRecord::Migration[5.2]
  def change
    create_table :styles do |t|
      t.references :owner, polymorphic: true, index: true, null: false
      t.string :name, null: false
      t.text :css, null: false

      t.timestamps null: false
    end
  end
end
