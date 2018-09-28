class RenameUserRatesLogsIntoUserRateLogs < ActiveRecord::Migration[5.2]
  def change
    rename_table :user_rates_logs, :user_rate_logs
  end
end
