class AddChangedAtToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :changed_at, :datetime
  end
end
