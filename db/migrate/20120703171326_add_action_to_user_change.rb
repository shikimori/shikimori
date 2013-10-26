class AddActionToUserChange < ActiveRecord::Migration
  def self.up
    add_column :user_changes, :action, :string
  end

  def self.down
    remove_column :user_changes, :action
  end
end
