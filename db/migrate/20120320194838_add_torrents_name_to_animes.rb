class AddTorrentsNameToAnimes < ActiveRecord::Migration
  def self.up
    add_column :animes, :torrents_name, :string
    Anime.where(:id => 9969).update_all(torrents_name: 'Gintama', episodes: 0)
  end

  def self.down
    remove_column :animes, :torrents_name
  end
end
