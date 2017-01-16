class RenameSourceInExternalLinks < ActiveRecord::Migration
  def change
    rename_column :external_links, :source, :kind
  end
end
