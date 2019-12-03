class FillOptionsForAnimesV2 < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.env.production?

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

    Anime
      .where(id: [
        10_161, 10_490, 10_379, 6336, 11_319, 14_645, 15_085, 14_967, 15_611,
        17_705, 15_699, 16_241, 16_049, 34_984
      ])
      .each do |anime|
        anime.options << Types::Anime::Options[:strict_torrent_name_match]
        anime.save!
      end
  end
end
