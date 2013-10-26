class RemoveTimestamptsFromContestUserVotes < ActiveRecord::Migration
  def up
    remove_column :contest_user_votes, :created_at
    remove_column :contest_user_votes, :updated_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
