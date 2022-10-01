module Types
  module WebmVideo
    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:pending, :processed, :failed)
  end
end
