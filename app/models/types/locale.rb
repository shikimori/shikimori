module Types
  Locale = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:ru, :en)
end
