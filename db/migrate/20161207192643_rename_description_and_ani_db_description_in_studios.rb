class RenameDescriptionAndAniDbDescriptionInStudios < ActiveRecord::Migration
  def change
    rename_column :studios, :description, :description_ru
    rename_column :studios, :ani_db_description, :description_en
  end
end
