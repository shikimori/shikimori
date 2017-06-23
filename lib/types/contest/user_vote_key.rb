module Types
  module Contest
    UserVoteKey = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:can_vote_1, :can_vote_2, :can_vote_3)
  end
end
