module Types
  module ListImport
    ListType = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anime, :manga)
  end
end

