class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :anime_id

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
