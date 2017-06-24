module Types
  module Topic::NewsTopic::ContestStatusTopic
    Action = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i(
        started
        finished
      ))
  end
end
