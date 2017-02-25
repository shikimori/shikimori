module Types
  Locale = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(*%i(ru en))
end
