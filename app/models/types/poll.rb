module Types
  module Poll
    Width = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:limited, :fullwidth)

    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:pending, :started, :stopped)
  end
end
