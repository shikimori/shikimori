class AddEpisodesAiredToAnimes < ActiveRecord::Migration
  def self.up
    add_column :animes, :episodes_aired, :integer
  end

  def self.down
    remove_column :animes, :episodes_aired
  end
end
