class AddAdditionalInfoToAnimesAndMangas < ActiveRecord::Migration[6.1]
  def change
    add_column :animes, :additional_info, :string
    add_column :mangas, :additional_info, :string
  end
end
