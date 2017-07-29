class AddStateToListImports < ActiveRecord::Migration[5.1]
  def change
    add_column :list_imports, :state, :string, null: false
  end
end
