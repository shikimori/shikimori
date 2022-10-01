module Types
  module ClubInvite
    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:pending, :closed)
  end
end
