class RemoveDefaultStateFromAbuseRequests < ActiveRecord::Migration
  def up
    change_column_default :abuse_requests, :state, nil
  end

  def down
    change_column_default :abuse_requests, :state, 'Pending'
  end
end
