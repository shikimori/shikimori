class AddFranchiseToMangas < ActiveRecord::Migration[5.1]
  def change
    add_column :mangas, :franchise, :string
  end
end
