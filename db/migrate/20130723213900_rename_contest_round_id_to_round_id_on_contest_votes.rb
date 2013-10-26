class RenameContestRoundIdToRoundIdOnContestVotes < ActiveRecord::Migration
  def change
    rename_column :contest_votes, :contest_round_id, :round_id
  end
end
