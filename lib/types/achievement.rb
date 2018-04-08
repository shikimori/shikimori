module Types
  module Achievement
    NEKO_GROUPS = %i[common genre franchise]
    NekoGroup = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_GROUPS)

    NEKO_IDS = {
      NekoGroup[:common] => %i[
        test

        animelist
        otaku
        fujoshi
        yuuri
        tsundere
        yandere
        kuudere
        moe
        oniichan
        mahou_shoujo
        oldfag
        sovietanime
      ],
      NekoGroup[:genre] => %i[
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
        shortie
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
        kids
      ]
    }
    INVERTED_NEKO_IDS = NEKO_IDS.each_with_object({}) do |(group, ids), memo|
      ids.each { |id| memo[id] = NekoGroup[group] }
    end
    ORDERED_NEKO_IDS = INVERTED_NEKO_IDS.keys

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ORDERED_NEKO_IDS)
  end
end
