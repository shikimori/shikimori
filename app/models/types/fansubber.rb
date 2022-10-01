module Types
  module Fansubber
    KINDS = %i[fansubber fandubber]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)
  end
end
