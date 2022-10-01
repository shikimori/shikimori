module Types
  module Topic::NewsTopic
    Action = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anons, :ongoing, :released, :episode)
  end
end
