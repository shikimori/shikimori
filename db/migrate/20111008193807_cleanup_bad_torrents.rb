class CleanupBadTorrents < ActiveRecord::Migration
  def self.up
    i = 0
    Anime.where("(released > '2008-01-01' || status = ?) and atype != 'TV' and atype != 'Movie'", AniMangaStatus::Ongoing).all.each do |anime|
      before = anime.torrents
      after = anime.torrents.select {|v| TorrentsMatcher.new(anime).matches_for(v[:title]) }
      if before.size != after.size
        anime.torrents = after
        anime.update_attributes({:episodes_aired => 0})
        anime.history.where(:action => AnimeHistoryAction::Episode).destroy_all
        i += 1
      end
    end
    puts "processed %d animes" % i
  end

  def self.down
  end
end
