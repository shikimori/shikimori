class AddStateToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :state, :string, null: false
  end
end
