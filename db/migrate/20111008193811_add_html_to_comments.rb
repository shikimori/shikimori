class AddHtmlToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :html, :boolean, :default => false
  end

  def self.down
    remove_column :comments, :default
  end
end
