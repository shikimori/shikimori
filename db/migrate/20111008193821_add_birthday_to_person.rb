class AddBirthdayToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :birthday, :date
    add_column :people, :given_name, :string
    add_column :people, :family_name, :string
    add_column :people, :website, :string
  end

  def self.down
    remove_column :people, :website
    remove_column :people, :family_name
    remove_column :people, :given_name
    remove_column :people, :birthday
  end
end
