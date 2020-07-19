class IncreaseUserRatesTextSize < ActiveRecord::Migration[5.2]
  def up
    change_column :user_rates, :text, :string, limit: 16384
  end

  def down
    change_column :user_rates, :text, :string, limit: 2048
  end
end
