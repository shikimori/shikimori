class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :src_id
      t.string :src_type
      t.integer :dst_id
      t.string :dst_type
      t.string :message_type
      t.text :body
      t.boolean :read

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
