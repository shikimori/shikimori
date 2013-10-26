class ResetProfileSettingsMangaAnime < ActiveRecord::Migration
  def self.up
    ProfileSettings.update_all anime: true, manga: true
  end
end
