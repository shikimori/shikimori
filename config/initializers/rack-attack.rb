# Throttle requests to 5 requests per second per ip
Rack::Attack.throttle('req/ip', limit: 5, period: 1.second) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.

  req.ip
end

Rack::Attack.throttle('req/ip', limit: 90, period: 60.second) do |req|
  req.ip
end
