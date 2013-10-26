class CreateGroupInvites < ActiveRecord::Migration
  def self.up
    create_table :group_invites do |t|
      t.integer :group_id
      t.integer :src_id
      t.integer :dst_id
      t.string :status, :default => GroupInviteStatus::Pending
      t.integer :message_id

      t.timestamps
    end
    add_index :group_invites,
              [:group_id, :dst_id, :status],
              :name => 'uniq_group_invites',
              :unique => true
  end

  def self.down
    drop_table :group_invites
  end
end
