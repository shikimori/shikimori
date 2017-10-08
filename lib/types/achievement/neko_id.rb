module Types
  module Achievement
    NEKO_IDS = %i[
      test
      action
      animelist
      comedy
      dementia_psychological
      drama
      fantasy
      fujoshi
      gar
      historical
      horror_thriller
      josei
      kuudere
      longshounen
      mahou_shoujo
      mecha
      military
      moe
      music
      mystery
      oldfag
      onniichan
      otaku
      police
      romance
      scifi
      seinen
      slice_of_life
      sovietanime
      space
      sports
      supernatural
      tsundere
      yandere
      yuuri
    ]

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_IDS)
  end
end
