class AddSourceToExternalLinks < ActiveRecord::Migration
  def change
    add_column :external_links, :source, :string, null: false
  end
end
