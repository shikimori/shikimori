class CreateAbuseRequests < ActiveRecord::Migration
  def self.up
    create_table :abuse_requests do |t|
      t.integer :user_id
      t.integer :comment_id
      t.string :kind
      t.boolean :value

      t.timestamps
    end
    add_index :abuse_requests, [:comment_id, :kind, :value], :unique => true
  end

  def self.down
    drop_table :abuse_requests
  end
end
