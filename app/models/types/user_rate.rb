module Types
  module UserRate
    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*::UserRate.statuses.keys.map(&:to_sym))
  end
end
