module Types
  module Review
    Opinion = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:positive, :neutral, :negative, :unknown)
  end
end
