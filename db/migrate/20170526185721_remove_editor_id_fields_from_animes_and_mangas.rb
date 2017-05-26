class RemoveEditorIdFieldsFromAnimesAndMangas < ActiveRecord::Migration[5.0]
  def change
    remove_column :animes, :editor_id, :integer
    remove_column :mangas, :editor_id, :integer
  end
end
