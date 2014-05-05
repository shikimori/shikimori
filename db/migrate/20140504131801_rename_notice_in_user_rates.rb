class RenameNoticeInUserRates < ActiveRecord::Migration
  def change
    rename_column :user_rates, :notice, :text
  end
end
