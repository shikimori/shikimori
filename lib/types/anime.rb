module Types
  module Anime
    Duration = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:S, :D, :F)

    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anons, :ongoing, :released, :planned, :latest)
  end
end
