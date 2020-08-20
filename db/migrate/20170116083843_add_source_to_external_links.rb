class AddSourceToExternalLinks < ActiveRecord::Migration[5.2]
  def change
    add_column :external_links, :source, :string, null: false
  end
end
