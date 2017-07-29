class AddOutputToListImports < ActiveRecord::Migration[5.1]
  def change
    add_column :list_imports, :output, :jsonb
  end
end
