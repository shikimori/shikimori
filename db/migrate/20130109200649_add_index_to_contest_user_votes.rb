class AddIndexToContestUserVotes < ActiveRecord::Migration
  def self.up
    add_index :contest_user_votes, :contest_vote_id
    add_index :contest_user_votes, [:contest_vote_id, :item_id]
  end

  def self.down
    remove_index :contest_user_votes, :contest_vote_id
    remove_index :contest_user_votes, [:contest_vote_id, :item_id]
  end
end
