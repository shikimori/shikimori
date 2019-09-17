class AddLicensorToAnimesAndMangas < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :licensor, :string
    add_column :mangas, :licensor, :string
  end
end
