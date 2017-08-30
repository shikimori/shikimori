class AddCachedUniqVotersToContests < ActiveRecord::Migration[5.1]
  def change
    add_column :contests, :cached_uniq_voters_count, :integer,
      null: false,
      default: 0
  end
end
