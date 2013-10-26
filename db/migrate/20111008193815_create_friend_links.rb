class CreateFriendLinks < ActiveRecord::Migration
  def self.up
    create_table :friend_links do |t|
      t.integer :src_id
      t.integer :dst_id

      t.timestamps
    end
  end

  def self.down
    drop_table :friend_links
  end
end
