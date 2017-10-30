module Types
  module Neko
    Action = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:noop, :put, :delete, :reset)
  end
end
