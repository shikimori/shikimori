class FixMultipleMangaFranchises < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call(
      Manga.where(
        franchise: Manga.where(
          id: %w[
            118865
            107458
            13891
            37755
            109217
            65169
            23556
            56725
            81575
            598
            96060
            7700
            40015
            59851
            82087
            77427
            112780
          ]
        ).select(:franchise)
      )
    )
    Animes::UpdateFranchises.new.call(
      Anime.where(
        franchise: Anime.where(
          id: %w[
            6115
          ]
        ).select(:franchise)
      )
    )
    Manga.where(franchise: 'pcp').update_all franchise: 'bakuman'
    Manga.where(franchise: 'case_closed').update_all franchise: 'detective_conan'
    Manga.where(franchise: 'toki').update_all franchise: 'saki'
    Manga.where(franchise: 'mayoe').update_all franchise: 'nanatsu_no_tanpen'
    Manga.where(franchise: 'haganai').update_all franchise: 'boku_wa_tomodachi_ga_sukunai'
  end
end
