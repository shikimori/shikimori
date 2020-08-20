class RenameSourceInExternalLinks < ActiveRecord::Migration[5.2]
  def change
    rename_column :external_links, :source, :kind
  end
end
