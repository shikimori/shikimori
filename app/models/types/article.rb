module Types
  module Article
    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:unpublished, :published)
  end
end
