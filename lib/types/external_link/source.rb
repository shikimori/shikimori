module Types
  module ExternalLink
    Source = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i(myanimelist shikimori))
  end
end
