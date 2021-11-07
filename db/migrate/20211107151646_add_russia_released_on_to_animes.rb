class AddRussiaReleasedOnToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :russia_released_on, :date
  end
end
