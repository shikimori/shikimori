module Types
  module Summary
    Opinion = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:positive, :neutral, :negative, :unknown)
  end
end
