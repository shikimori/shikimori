class AddConfirmedToCosplayGallery < ActiveRecord::Migration
  def self.up
    add_column :cosplay_galleries, :confirmed, :boolean, :default => false
  end

  def self.down
    remove_column :cosplay_galleries, :confirmed
  end
end
