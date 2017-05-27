module Types
  module Anime
    Duration = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:S, :D, :F)
  end
end
