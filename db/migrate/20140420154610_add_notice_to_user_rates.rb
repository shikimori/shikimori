class AddNoticeToUserRates < ActiveRecord::Migration
  def change
    add_column :user_rates, :notice, :string, limit: 1024
  end
end
