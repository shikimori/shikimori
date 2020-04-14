class FixArticlesFieldV2 < ActiveRecord::Migration[5.2]
  def change
    rename_column :articles, :text, :body
  end
end
