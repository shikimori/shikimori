class AddFandubbersToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :fandubbers, :text, array: true, default: [], null: false
  end
end
