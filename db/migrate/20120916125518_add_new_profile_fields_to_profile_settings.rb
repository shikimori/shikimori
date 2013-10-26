class AddNewProfileFieldsToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :manga_first, :boolean, default: false
    add_column :profile_settings, :russian_names, :boolean, default: false
    add_column :profile_settings, :about_on_top, :boolean, default: false
  end

  def self.down
    remove_column :profile_settings, :manga_first
    remove_column :profile_settings, :russian_names
    remove_column :profile_settings, :about_on_top
  end
end
