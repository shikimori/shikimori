class AddOptionsToAnimesV2 < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.env.production?

    add_column :animes, :options, :string, default: [], null: false, array: true
  end
end
