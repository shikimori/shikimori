class RemoveDescriptionHtmlFromAnimes < ActiveRecord::Migration
  def change
    remove_column :animes, :description_html, :text
  end
end
