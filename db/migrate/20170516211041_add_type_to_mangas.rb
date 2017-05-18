class AddTypeToMangas < ActiveRecord::Migration[5.0]
  def change
    add_column :mangas, :type, :string
  end
end
