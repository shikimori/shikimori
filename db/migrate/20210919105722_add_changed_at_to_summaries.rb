class AddChangedAtToSummaries < ActiveRecord::Migration[5.2]
  def change
    add_column :summaries, :changed_at, :datetime
  end
end
