module Types
  module Achievement
    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:test)
  end
end
