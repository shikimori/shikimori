class AllowNullAttachmentInListImports < ActiveRecord::Migration[5.2]
  def up
    change_column :list_imports, :list_file_name, :string, null: true
    change_column :list_imports, :list_content_type, :string, null: true
    change_column :list_imports, :list_file_size, :integer, null: true
    change_column :list_imports, :list_updated_at, :datetime, null: true
  end
end
