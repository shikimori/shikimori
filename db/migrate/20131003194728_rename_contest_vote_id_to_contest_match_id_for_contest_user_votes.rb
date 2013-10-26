class RenameContestVoteIdToContestMatchIdForContestUserVotes < ActiveRecord::Migration
  def change
    rename_column :contest_user_votes, :contest_vote_id, :contest_match_id
  end
end
