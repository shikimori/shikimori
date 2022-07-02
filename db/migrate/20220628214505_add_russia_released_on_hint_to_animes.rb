class AddRussiaReleasedOnHintToAnimes < ActiveRecord::Migration[6.1]
  def change
    add_column :animes, :russia_released_on_hint, :text, null: false, default: ''
  end
end
