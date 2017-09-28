module Types
  module Achievement
    NEKO_IDS = %i[
      test
      animelist
      comedy
      otaku
    ]

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_IDS)
  end
end
