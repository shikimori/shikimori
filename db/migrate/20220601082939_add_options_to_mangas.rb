class AddOptionsToMangas < ActiveRecord::Migration[6.1]
  def change
    add_column :mangas, :options, :string,
      default: [],
      null: false,
      array: true
  end
end
