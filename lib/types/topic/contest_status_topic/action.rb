module Types
  module Topic::ContestStatusTopic
    Action = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i(
        started
        finished
      ))
  end
end
