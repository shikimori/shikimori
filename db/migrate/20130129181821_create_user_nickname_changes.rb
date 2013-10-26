class CreateUserNicknameChanges < ActiveRecord::Migration
  def self.up
    create_table :user_nickname_changes do |t|
      t.integer :user_id
      t.string :value

      t.timestamps
    end
    add_index :user_nickname_changes, :user_id
    add_index :user_nickname_changes, [:user_id, :value], unique: true
  end

  def self.down
    drop_table :user_nickname_changes
  end
end
