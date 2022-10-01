class RenameIsThematicToIsNonThematic < ActiveRecord::Migration[6.1]
  def change
    rename_column :clubs, :is_thematic, :is_non_thematic
  end
end
