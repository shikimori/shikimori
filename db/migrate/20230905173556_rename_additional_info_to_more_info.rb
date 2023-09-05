class RenameAdditionalInfoToMoreInfo < ActiveRecord::Migration[6.1]
  def change
    rename_column :animes, :additional_info, :more_info
    rename_column :mangas, :additional_info, :more_info
  end
end
