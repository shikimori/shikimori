class AddCachedVotesUpAndCachedVotesDownToSummaries < ActiveRecord::Migration[5.2]
  def change
    add_column :summaries, :cached_votes_up, :integer,
      default: false,
      null: false
    add_column :summaries, :cached_votes_down, :integer,
      default: false,
      null: false
  end
end
