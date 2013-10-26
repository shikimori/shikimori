class AddOfftopicToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :offtopic, :boolean, default: false
  end

  def self.down
    remove_column :comments, :offtopic
  end
end
