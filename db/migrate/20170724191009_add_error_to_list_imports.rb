class AddErrorToListImports < ActiveRecord::Migration[5.1]
  def change
    add_column :list_imports, :error, :text
  end
end
