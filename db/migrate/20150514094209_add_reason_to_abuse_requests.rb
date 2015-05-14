class AddReasonToAbuseRequests < ActiveRecord::Migration
  def change
    add_column :abuse_requests, :reason, :string
  end
end
