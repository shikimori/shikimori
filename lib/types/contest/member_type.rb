module Types
  module Contest
    MemberType = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anime, :character)
  end
end
