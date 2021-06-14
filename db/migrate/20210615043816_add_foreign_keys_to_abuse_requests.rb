class AddForeignKeysToAbuseRequests < ActiveRecord::Migration[5.2]
  def change
    change_column :abuse_requests, :user_id, :integer,
      null: false
    add_foreign_key :abuse_requests, :users, column: :user_id

    change_column :abuse_requests, :comment_id, :integer,
      null: false
    add_foreign_key :abuse_requests, :comments

    add_foreign_key :abuse_requests, :users, column: :approver_id

    change_column :abuse_requests, :created_at, :datetime,
      null: false
    change_column :abuse_requests, :updated_at, :datetime,
      null: false
  end
end
