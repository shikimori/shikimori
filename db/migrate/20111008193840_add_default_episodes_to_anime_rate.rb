class AddDefaultEpisodesToAnimeRate < ActiveRecord::Migration
  def self.up
    change_column :anime_rates, :episodes, :integer, :null => false, :default => 0
  end

  def self.down
    change_column :anime_rates, :episodes, :integer
  end
end
