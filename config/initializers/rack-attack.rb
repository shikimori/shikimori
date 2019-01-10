NEKO_IP = '88.198.7.116'
SMOTRET_ANIME_USER_AGENT = 'Anime 365 (https://smotretanime.ru/; info@smotretanime.ru)'

Rack::Attack.safelist_ip NEKO_IP

# Throttle requests to 5 requests per second per ip
Rack::Attack.throttle('req/ip', limit: 5, period: 1.second) do |req|
  # If the return value is truthy, the cache key for the return value
  # is incremented and compared with the limit. In this case:
  #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
  #
  # If falsy, the cache key is neither incremented nor checked.

  # requests from neko are allowed
  if req.user_agent != SMOTRET_ANIME_USER_AGENT
    req.ip
  end
end


Rack::Attack.throttle('req/ip', limit: 15, period: 1.second) do |req|
  if req.user_agent == SMOTRET_ANIME_USER_AGENT
    req.ip
  end
end

Rack::Attack.throttle('req/ip', limit: 90, period: 60.second) do |req|
  # requests from neko are allowed
  if req.user_agent != SMOTRET_ANIME_USER_AGENT
    req.ip
  end
end

Rack::Attack.throttle('req/ip', limit: 270, period: 60.second) do |req|
  if req.user_agent == SMOTRET_ANIME_USER_AGENT
    req.ip
  end
end

if ENV['SHIKI_TYPE'] == 'db'
  Rack::Attack.throttle('req/ip', limit: 2, period: 1.second) do |req|
    if req.url =~ %r{/video_online(?:/|$)}
      req.ip
    end
  end

  Rack::Attack.throttle('req/ip', limit: 40, period: 1.minute) do |req|
    if req.url =~ %r{/video_online(?:/|$)}
      req.ip
    end
  end

  Rack::Attack.throttle('req/ip', limit: 500, period: 1.hour) do |req|
    if req.url =~ %r{/video_online(?:/|$)}
      req.ip
    end
  end

  Rack::Attack.throttle('req/ip', limit: 2000, period: 1.day) do |req|
    if req.url =~ %r{/video_online(?:/|$)}
      req.ip
    end
  end
end
