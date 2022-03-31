class RemoveReviewIdInBansAndInAbuseRequests < ActiveRecord::Migration[5.2]
  def up
    remove_column :abuse_requests, :review_id
    remove_column :bans, :review_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
