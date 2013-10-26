class RemoveDcBotMessages < ActiveRecord::Migration
  def self.up
    drop_table :dc_bot_messages
  end

  def self.down
    create_table :dc_bot_messages do |t|
      t.text :text
      t.boolean :processed, :default => false

      t.timestamps
    end
  end
end
