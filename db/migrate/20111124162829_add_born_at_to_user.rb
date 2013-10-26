class AddBornAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :birth_at, :date
  end

  def self.down
    remove_column :users, :birth_at
  end
end
