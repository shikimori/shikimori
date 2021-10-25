class AddChangedAtToReviewsV2 < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :changed_at, :datetime
  end
end
