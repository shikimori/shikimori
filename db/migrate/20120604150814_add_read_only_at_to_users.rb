class AddReadOnlyAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :read_only_at, :datetime
  end

  def self.down
    remove_column :users, :read_only_at
  end
end
