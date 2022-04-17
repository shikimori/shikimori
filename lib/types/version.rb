module Types
  module Version
    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:pending, :accepted, :auto_accepted, :rejected, :taken, :deleted)
  end
end
