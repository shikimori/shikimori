class CreateBans < ActiveRecord::Migration
  def change
    create_table :bans do |t|
      t.references :user
      t.references :comment
      t.references :abuse_request
      t.integer :moderator_id
      t.integer :duration
      t.text :reason

      t.timestamps
    end
    add_index :bans, :user_id
    add_index :bans, :comment_id
    add_index :bans, :abuse_request_id
    add_index :bans, :moderator_id
  end
end
