module Types
  module Contest
    StrategyType = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:double_elimination, :play_off, :swiss)
  end
end
