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
      onniichan
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
