class AddDefaultsToUserRates < ActiveRecord::Migration
  def up
    change_column_default :user_rates, :score, 0
    change_column_default :user_rates, :status, 0

    UserRate.where(score: nil).update_all score: 0
    UserRate.where(status: nil).update_all status: 0

    change_column :user_rates, :score, :integer, default: 0, null: false
    change_column :user_rates, :status, :integer, default: 0, null: false
  end

  def down
    change_column_default :user_rates, :score, nil
    change_column_default :user_rates, :status, nil

    change_column :user_rates, :score, :integer, null: true
    change_column :user_rates, :status, :integer, null: true
  end
end
