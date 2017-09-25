module Types
  module Achievement
    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i[
        test
        animelist
      ])
  end
end
