class DropFullnameFromPerson < ActiveRecord::Migration
  def self.up
    remove_column :people, :fullname
  end

  def self.down
    add_column :people, :fullname, :string
  end
end
