class MakeAbuseRequestsReabusable < ActiveRecord::Migration
  def change
    remove_index :abuse_requests, column: [:comment_id, :kind, :value], unique: true
    add_index :abuse_requests, [:comment_id, :kind, :value], where: "(state = 'pending')", unique: true
  end
end
