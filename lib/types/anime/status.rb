module Types
  module Anime
    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i(anons ongoing released planned latest))
  end
end
