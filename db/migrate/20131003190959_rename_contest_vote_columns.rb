class RenameContestVoteColumns < ActiveRecord::Migration
  def up
    rename_column :contests, :votes_per_round, :matches_per_round
    rename_column :contests, :vote_duration, :match_duration
    rename_column :contests, :vote_interval, :matches_interval
  end
end
