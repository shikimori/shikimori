class AddCachedVotesUpAndCachedVotesDownToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :cached_votes_up, :integer,
      default: false,
      null: false
    add_column :reviews, :cached_votes_down, :integer,
      default: false,
      null: false
  end
end
