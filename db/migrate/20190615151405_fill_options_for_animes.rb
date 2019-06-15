class FillOptionsForAnimes < ActiveRecord::Migration[5.2]
  def change
    Anime
      .where(id: 26123)
      .each do |anime|
        anime.options << Types::Anime::Options[:disabled_anime365_sync]
        anime.options << Types::Anime::Options[:disabled_torrents_sync]
        anime.save!
      end

    Anime
      .where(id: [
        13_185, 19_207, 5042, 17_249, 11_457, 21_729, 22_757, 32_670, 31_670,
        31_592, 10_937, 34_454, 31_499, 37_277, 2406
      ])
      .each do |anime|
        anime.options << Types::Anime::Options[:disabled_torrents_sync]
        anime.save!
      end
  end
end
