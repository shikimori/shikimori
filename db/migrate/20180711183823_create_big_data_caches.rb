class CreateBigDataCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :big_data_caches do |t|
      t.string :key, null: false
      t.text :value, null: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :big_data_caches, :key, unique: true
  end
end
