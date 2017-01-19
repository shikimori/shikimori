module Types
  module Club
    CommentPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:free, :members)
  end
end
