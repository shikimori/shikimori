class RenameReviewsSection < ActiveRecord::Migration
  def up
    Section.find(12).update_column :permalink, 'reviews'
  end

  def down
    Section.find(12).update_column :permalink, 'r'
  end
end
