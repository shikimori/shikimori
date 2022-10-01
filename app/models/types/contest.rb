module Types
  module Contest
    UserVoteKey = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:can_vote_1, :can_vote_2, :can_vote_3)

    StrategyType = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:double_elimination, :play_off, :swiss)

    MemberType = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anime, :character)

    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:created, :proposing, :started, :finished)
  end
end
