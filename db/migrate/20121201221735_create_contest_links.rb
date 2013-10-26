class CreateContestLinks < ActiveRecord::Migration
  def self.up
    create_table :contest_links do |t|
      t.integer :contest_id
      t.integer :linked_id
      t.string :linked_type

      t.timestamps
    end
  end

  def self.down
    drop_table :contest_links
  end
end
