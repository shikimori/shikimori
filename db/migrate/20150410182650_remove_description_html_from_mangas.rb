class RemoveDescriptionHtmlFromMangas < ActiveRecord::Migration
  def change
    remove_column :mangas, :description_html, :text
  end
end
