class MorePerformanceIndexes < ActiveRecord::Migration
  def self.up
    add_index :user_rates, [:user_id, :target_type], :name => :i_user_target
  end

  def self.down
    remove_index :user_rates, :i_user_target
  end
end
