class AddFansubbersToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :fansubbers, :text, array: true, default: [], null: false
  end
end
