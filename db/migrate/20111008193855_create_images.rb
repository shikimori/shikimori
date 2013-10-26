class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :uploader_id

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
