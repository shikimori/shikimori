class CreateDcBotMessages < ActiveRecord::Migration
  def self.up
    create_table :dc_bot_messages do |t|
      t.text :text
      t.boolean :processed, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :dc_bot_messages
  end
end
