module Types
  module Comment
    CommentableType = Types::Strict::String
      .constructor(&:to_sym)
      .enum('Topic', 'User', 'Review')
  end
end
