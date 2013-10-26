class AddCommentsToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :comments, :boolean, default: true
  end

  def self.down
    remove_column :profile_settings, :comments
  end
end
