class AddOptionsToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :options, :string, default: [], null: false, array: true
  end
end
