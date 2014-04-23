class AddRewatchesToUserRates < ActiveRecord::Migration
  def change
    add_column :user_rates, :rewatches, :integer, default: 0, null: false
  end
end
