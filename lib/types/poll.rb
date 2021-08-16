module Types
  module Poll
    Width = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:limited, :fullwidth)
  end
end
