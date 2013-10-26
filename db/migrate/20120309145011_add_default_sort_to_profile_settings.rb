class AddDefaultSortToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :default_sort, :string, :default => ProfileSettings::DefaultSort, :null => false
  end

  def self.down
    remove_column :profile_settings, :default_sort
  end
end
