module Types
  module ContestRound
    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:created, :started, :finished)
  end
end
