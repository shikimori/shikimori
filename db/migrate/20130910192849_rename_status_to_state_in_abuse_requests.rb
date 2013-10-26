class RenameStatusToStateInAbuseRequests < ActiveRecord::Migration
  def change
    rename_column :abuse_requests, :status, :state
  end
end
