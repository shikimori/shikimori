class TemporarilyAddIsSummaryToComment < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :is_summary, :boolean,
      default: false,
      null: false
  end
end
