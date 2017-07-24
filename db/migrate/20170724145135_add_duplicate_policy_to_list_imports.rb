class AddDuplicatePolicyToListImports < ActiveRecord::Migration[5.1]
  def change
    add_column :list_imports, :duplicate_policy, :string, null: false
  end
end
