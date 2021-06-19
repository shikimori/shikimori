module Types
  module Summary
    Tone = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:positive, :neutral, :negative)
  end
end
