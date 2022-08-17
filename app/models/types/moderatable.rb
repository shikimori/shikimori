module Types
  module Moderatable
    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:pending, :accepted, :rejected)
  end
end
