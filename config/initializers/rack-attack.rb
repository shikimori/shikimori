module Rack::Attack::Request::RealIpFix
  def real_ip
    env['HTTP_X_FORWARDED_FOR']&.split(',')&.first ||
      env['HTTP_X_REAL_IP'] ||
      env['REMOTE_ADDR'] ||
      ip
  end
end
Rack::Attack::Request.send :include, Rack::Attack::Request::RealIpFix

NEKO_IP = '88.198.7.116'
SMOTRET_ANIME_USER_AGENT = 'Anime 365 (https://smotretanime.ru/; info@smotretanime.ru)'

Rack::Attack.safelist('neko') do |req|
  req.real_ip == NEKO_IP
end

Rack::Attack.safelist('screenshots_upload') do |req|
  request.post? && request.path.ends_with?('/screenshots')
end

if Rails.env.development?
  Rack::Attack.safelist('localhost') do |req|
    req.real_ip == '127.0.0.1'
  end
end

# Throttle requests to 5 requests per second per ip
Rack::Attack.throttle('req/ip', limit: 5, period: 1.second) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.
  if req.user_agent != SMOTRET_ANIME_USER_AGENT && !req.url.include?('/autocomplete')
    req.real_ip
  end
end


Rack::Attack.throttle('per second', limit: 15, period: 1.second) do |req|
  if req.user_agent == SMOTRET_ANIME_USER_AGENT && !req.url.include?('/autocomplete')
    req.real_ip
  end
end

Rack::Attack.throttle('per minute', limit: 90, period: 60.second) do |req|
  if req.user_agent != SMOTRET_ANIME_USER_AGENT && !req.url.include?('/autocomplete')
    req.real_ip
  end
end

Rack::Attack.throttle('smotret-anime per minute', limit: 270, period: 60.second) do |req|
  if req.user_agent == SMOTRET_ANIME_USER_AGENT
    req.real_ip
  end
end
