class AddLicenseNameRuToAnimesAndMangas < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :license_name_ru, :string
    add_column :mangas, :license_name_ru, :string
  end
end
