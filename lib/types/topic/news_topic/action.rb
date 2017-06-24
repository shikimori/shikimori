module Types
  module Topic::NewsTopic
    Action = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i(
        anons
        ongoing
        released
        episode
      ))
  end
end
