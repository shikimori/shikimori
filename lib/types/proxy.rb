module Types
  module Proxy
    Protocol = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:http, :socks)
  end
end
