module Types
  module Version
    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:pending, :accepted, :auto_accepted, :taken, :rejected, :deleted)
  end
end
