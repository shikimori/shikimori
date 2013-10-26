class ChangeOfficialSiteToWebsiteStudio < ActiveRecord::Migration
  def self.up
    rename_column :studios, :official_site, :website
  end

  def self.down
    rename_column :studios, :website, :official_site
  end
end
