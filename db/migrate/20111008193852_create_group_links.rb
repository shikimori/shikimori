class CreateGroupLinks < ActiveRecord::Migration
  def self.up
    create_table :group_links do |t|
      t.integer :group_id
      t.integer :linked_id
      t.string :linked_type

      t.timestamps
    end
  end

  def self.down
    drop_table :group_links
  end
end
