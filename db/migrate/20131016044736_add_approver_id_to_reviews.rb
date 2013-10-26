class AddApproverIdToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :approver_id, :integer
  end
end
