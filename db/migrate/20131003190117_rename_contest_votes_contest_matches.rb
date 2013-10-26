class RenameContestVotesContestMatches < ActiveRecord::Migration
  def change
    rename_table :contest_votes, :contest_matches
  end
end
