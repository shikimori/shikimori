class RenameCanVoteToCanVote1 < ActiveRecord::Migration
  def self.up
    rename_column :users, :can_vote, :can_vote_1
  end

  def self.down
    rename_column :users, :can_vote_1, :can_vote
  end
end
