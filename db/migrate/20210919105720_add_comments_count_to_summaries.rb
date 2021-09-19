class AddCommentsCountToSummaries < ActiveRecord::Migration[5.2]
  def change
    add_column :summaries, :comments_count, :integer,
      null: false,
      default: 0
  end
end
