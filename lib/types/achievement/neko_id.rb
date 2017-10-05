module Types
  module Achievement
    NEKO_IDS = %i[
      test
      animelist
      fujoshi
      longshounen
      moe
      otaku
      sovietanime
      tsundere
      yandere
      comedy
    ]

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_IDS)
  end
end
