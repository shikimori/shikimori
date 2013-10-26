class CreateGroupRoles < ActiveRecord::Migration
  def self.up
    create_table :group_roles do |t|
      t.string :role, :default => GroupRole::Member
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
    add_index :group_roles,
              [:user_id, :group_id],
              :name => 'uniq_user_in_group',
              :unique => true
  end

  def self.down
    drop_table :group_roles
  end
end
