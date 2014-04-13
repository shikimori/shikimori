class AddDescriptionToGenres < ActiveRecord::Migration
  def change
    add_column :genres, :description, :text
  end
end
