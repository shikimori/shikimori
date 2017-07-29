class AddListTypeToListImports < ActiveRecord::Migration[5.1]
  def change
    add_column :list_imports, :list_type, :string, null: false
  end
end
