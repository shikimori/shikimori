module Types
  module ListImport
    DuplicatePolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:replace, :ignore)

    ListType = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anime, :manga)
  end
end
