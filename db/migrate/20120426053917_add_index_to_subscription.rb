class AddIndexToSubscription < ActiveRecord::Migration
  def self.up
    add_index :subscriptions, [:user_id, :target_type]
  end

  def self.down
    remove_index :subscriptions, [:user_id, :target_type]
  end
end
