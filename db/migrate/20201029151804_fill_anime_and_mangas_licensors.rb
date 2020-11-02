class FillAnimeAndMangasLicensors < ActiveRecord::Migration[5.2]
  def change
    Anime.where.not(licensor: '').find_each do |anime|
      anime.update! licensors: [anime.licensor]
    end

    Manga.where.not(licensor: '').find_each do |manga|
      manga.update! licensors: [manga.licensor]
    end
  end
end
