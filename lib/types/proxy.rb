module Types
  module Proxy
    # protocols: https://gitlab.com/honeyryderchuck/httpx/-/wikis/Proxy
    Protocol = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:http, :socks)
  end
end
