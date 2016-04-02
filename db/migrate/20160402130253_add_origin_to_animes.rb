class AddOriginToAnimes < ActiveRecord::Migration
  def change
    add_column :animes, :origin, :string
  end
end
