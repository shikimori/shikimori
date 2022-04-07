class RemoveIsSummaryFromCommentsV2 < ActiveRecord::Migration[6.0]
  def change
    remove_column :comments, :is_summary, :boolean,
      default: false,
      null: false
  end
end
