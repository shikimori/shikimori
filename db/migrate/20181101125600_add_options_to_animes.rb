class AddOptionsToAnimes < ActiveRecord::Migration[5.2]
  def change
    return if Rails.env.production?
    return if ENV['USER'] == 'morr'

    add_column :animes, :options, :string, default: [], null: false, array: true
  end
end
