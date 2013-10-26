class AddSourceToUserChange < ActiveRecord::Migration
  def self.up
    add_column :user_changes, :source, :string
  end

  def self.down
    remove_column :user_changes, :source
  end
end
