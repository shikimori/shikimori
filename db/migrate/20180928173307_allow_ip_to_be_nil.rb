class AllowIpToBeNil < ActiveRecord::Migration[5.2]
  def change
    change_column :user_rates_logs, :ip, :inet, null: true
  end
end
