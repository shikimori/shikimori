class AddCachedVotesToContestMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :contest_matches, :cached_votes_up, :integer, default: 0
    add_column :contest_matches, :cached_votes_down, :integer, default: 0
    add_column :contest_matches, :cached_votes_total, :integer, default: 0
  end
end
