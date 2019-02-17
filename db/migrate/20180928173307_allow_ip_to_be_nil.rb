class AllowIpToBeNil < ActiveRecord::Migration[5.2]
  def up
    change_column :user_rates_logs, :ip, :inet, null: true
  end

  def down
    change_column :user_rates_logs, :ip, :inet, null: false
  end
end
