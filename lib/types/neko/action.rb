module Types
  module Neko
    Action = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:noop, :create, :update, :destroy)
  end
end
