class AddPriorValueToUserHistory < ActiveRecord::Migration
  def self.up
    add_column :user_histories, :prior_value, :string
  end

  def self.down
    remove_column :user_histories, :prior_value
  end
end
