module Types
  module Licensor
    KINDS = %i[anime manga]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)
  end
end
