class ChangeSizeOfUserRatesText < ActiveRecord::Migration
  def change
    change_column :user_rates, :text, :string, limit: 2048
  end
end
