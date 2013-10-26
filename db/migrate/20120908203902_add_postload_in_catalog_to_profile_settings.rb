class AddPostloadInCatalogToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :postload_in_catalog, :boolean, default: true
  end

  def self.down
    remove_column :profile_settings, :postload_in_catalog
  end
end
