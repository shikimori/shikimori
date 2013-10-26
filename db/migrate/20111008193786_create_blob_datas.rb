class CreateBlobDatas < ActiveRecord::Migration
  def self.up
    create_table :blob_datas do |t|
      t.string :key
      t.text :value

      t.timestamps
    end
    add_index :blob_datas, :key, :unique => true
  end

  def self.down
    drop_table :blob_datas
  end
end
