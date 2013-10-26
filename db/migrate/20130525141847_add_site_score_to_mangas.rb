class AddSiteScoreToMangas < ActiveRecord::Migration
  def change
    add_column :mangas, :site_score, :float, default: 0.0, null: false
  end
end
