class AddChangedAtToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :critiques, :changed_at, :datetime
  end
end
