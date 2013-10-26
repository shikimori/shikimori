class AddSocialToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :social, :boolean, :default => true
  end

  def self.down
    remove_column :users, :social
  end
end
