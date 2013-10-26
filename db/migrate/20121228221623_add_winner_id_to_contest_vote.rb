class AddWinnerIdToContestVote < ActiveRecord::Migration
  def self.up
    add_column :contest_votes, :winner_id, :integer
  end

  def self.down
    remove_column :contest_votes, :winner_id
  end
end
