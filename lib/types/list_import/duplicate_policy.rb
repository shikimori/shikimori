module Types
  module ListImport
    DuplicatePolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:replace, :ignore)
  end
end

