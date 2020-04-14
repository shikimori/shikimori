class FixArticlesField < ActiveRecord::Migration[5.2]
  def change
    rename_column :articles, :body, :text
  end
end
