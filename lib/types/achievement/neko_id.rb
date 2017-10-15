module Types
  module Achievement
    NEKO_IDS = %i[
      test

      animelist
      otaku
      fujoshi
      yuuri
      tsundere
      yandere
      kuudere
      oniichan
      mahou_shoujo
      oldfag
      sovietanime
      moe

      action
      comedy
      dementia_psychological
      drama
      fantasy
      gar
      historical
      horror_thriller
      josei
      longshounen
      mecha
      military
      music
      mystery
      police
      romance
      scifi
      seinen
      slice_of_life
      space
      sports
      supernatural
    ]

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_IDS)
  end
end
