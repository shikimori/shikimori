class MakeUserRateLogsUserAgentNullable < ActiveRecord::Migration[5.2]
  def up
    change_column :user_rate_logs, :user_agent, :string, null: true
  end

  def down
    change_column :user_rate_logs, :user_agent, :string, null: false
  end
end
