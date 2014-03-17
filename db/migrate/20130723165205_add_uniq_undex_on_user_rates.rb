class AddUniqUndexOnUserRates < ActiveRecord::Migration
  def change
    add_index :user_rates, [:user_id, :target_id, :target_type], unique: true
  end
end
