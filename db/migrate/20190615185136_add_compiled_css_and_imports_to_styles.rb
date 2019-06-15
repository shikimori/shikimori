class AddCompiledCssAndImportsToStyles < ActiveRecord::Migration[5.2]
  def change
    add_column :styles, :compiled_css, :text
    add_column :styles, :imports, :text, array: true, null: true
  end
end
