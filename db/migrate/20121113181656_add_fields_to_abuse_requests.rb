class AddFieldsToAbuseRequests < ActiveRecord::Migration
  def self.up
    add_column :abuse_requests, :status, :string, :default => 'pending'
    add_column :abuse_requests, :approver_id, :integer
  end

  def self.down
    remove_column :abuse_requests, :approver_id
    remove_column :abuse_requests, :status
  end
end
