class AddCanVoteToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :can_vote, :boolean, default: false, null: false
  end

  def self.down
    remove_column :users, :can_vote
  end
end
