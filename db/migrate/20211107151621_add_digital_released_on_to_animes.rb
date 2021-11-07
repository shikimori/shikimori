class AddDigitalReleasedOnToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :digital_released_on, :date
  end
end
