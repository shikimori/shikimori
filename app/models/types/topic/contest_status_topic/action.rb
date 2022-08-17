module Types
  module Topic::ContestStatusTopic
    Action = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:started, :finished)
  end
end
