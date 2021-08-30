module Rack::Attack::Request::RealIpFix
  def real_ip
    env['HTTP_X_FORWARDED_FOR']&.split(',')&.first ||
      env['HTTP_X_REAL_IP'] ||
      env['REMOTE_ADDR'] ||
      ip
  end
end
Rack::Attack::Request.send :include, Rack::Attack::Request::RealIpFix

NEKO_IP = '135.181.210.175'
SMOTRET_ANIME_USER_AGENT = 'Anime 365 (https://smotretanime.ru/; info@smotretanime.ru)'

Rack::Attack.safelist('neko') do |req|
  req.real_ip == NEKO_IP
end

Rack::Attack.safelist('screenshots_upload') do |req|
  req.post? && req.path.ends_with?('/screenshots')
end

Rack::Attack.safelist('autocomplete_and_search_and_shiki_editor') do |req|
  req.get? && (
    req.path.ends_with?('/autocomplete') ||
    req.env['REQUEST_URI']&.starts_with?('/api/users?search=') ||
    req.path.starts_with?('/api/shiki_editor')
  )
end

if Rails.env.development?
  Rack::Attack.safelist('localhost') do |req|
    req.real_ip == '127.0.0.1'
  end
end

MODIFIER = 10

# Throttle requests to 5 requests per second per ip
Rack::Attack.throttle('req/ip', limit: 5 * MODIFIER, period: 1.second) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.
  if req.user_agent != SMOTRET_ANIME_USER_AGENT
    req.real_ip
  end
end

Rack::Attack.throttle('per second', limit: 15 * MODIFIER, period: 1.second) do |req|
  if req.user_agent == SMOTRET_ANIME_USER_AGENT
    req.real_ip
  end
end

Rack::Attack.throttle('per minute', limit: 90 * MODIFIER, period: 60.second) do |req|
  if req.user_agent != SMOTRET_ANIME_USER_AGENT
    req.real_ip
  end
end

Rack::Attack.throttle('smotret-anime per minute', limit: 270 * MODIFIER, period: 60.second) do |req|
  if req.user_agent == SMOTRET_ANIME_USER_AGENT
    req.real_ip
  end
end
