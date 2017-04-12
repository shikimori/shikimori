module Types
  module Club
    TopicPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:members, :admins)
  end
end
