class AddSiteScoreToAnimes < ActiveRecord::Migration
  def change
    add_column :animes, :site_score, :float, default: 0.0, null: false
  end
end
