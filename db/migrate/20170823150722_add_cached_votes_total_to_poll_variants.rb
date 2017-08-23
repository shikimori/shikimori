class AddCachedVotesTotalToPollVariants < ActiveRecord::Migration[5.1]
  def change
    add_column :poll_variants, :cached_votes_total, :integer, default: 0
  end
end
