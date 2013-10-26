class AddCanVote2ToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :can_vote_2, :boolean, default: false, null: false
  end

  def self.down
    remove_column :users, :can_vote_2
  end
end
