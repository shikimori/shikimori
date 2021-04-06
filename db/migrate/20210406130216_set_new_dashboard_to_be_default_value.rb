class SetNewDashboardToBeDefaultValue < ActiveRecord::Migration[5.2]
  def change
    change_column_default :user_preferences, :dashboard_type,
      from: :old,
      to: :new
  end
end
