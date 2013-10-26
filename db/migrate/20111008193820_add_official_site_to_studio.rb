class AddOfficialSiteToStudio < ActiveRecord::Migration
  def self.up
    add_column :studios, :official_site, :string
  end

  def self.down
    remove_column :studios, :official_site
  end
end
