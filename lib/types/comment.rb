module Types
  module Comment
    CommentableType = Types::Strict::String.enum('Topic', 'User', 'Review')
  end
end
