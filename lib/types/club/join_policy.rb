module Types
  module Club
    JoinPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:free, :admin_invite, :owner_invite)
  end
end
