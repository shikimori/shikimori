module Types
  module Collection
    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:unpublished, :published)
  end
end
