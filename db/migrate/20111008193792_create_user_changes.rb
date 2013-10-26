class CreateUserChanges < ActiveRecord::Migration
  def self.up
    create_table :user_changes do |t|
      t.integer :user_id
      t.integer :item_id
      t.string :model
      t.string :column
      t.text :value
      t.text :prior
      t.string :status, :default => UserChangeStatus::Pending
      t.integer :approver_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_changes
  end
end
