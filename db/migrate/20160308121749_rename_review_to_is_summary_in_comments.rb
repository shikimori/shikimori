class RenameReviewToIsSummaryInComments < ActiveRecord::Migration
  def change
    rename_column :comments, :review, :is_summary
    AbuseRequest.where(kind: :review).update_all kind: :summary
  end
end
