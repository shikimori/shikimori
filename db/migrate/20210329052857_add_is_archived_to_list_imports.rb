class AddIsArchivedToListImports < ActiveRecord::Migration[5.2]
  def change
    add_column :list_imports, :is_archived, :boolean, null: false, default: false
  end
end
