if defined? Rack::MiniProfiler
  # MemoryStore, RedisStore, MemcacheStore, and FileStore
  # Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore
  Rack::MiniProfiler.config.position = 'right'
  Rack::MiniProfiler.config.skip_paths = %w(
    /sponsors/
    /assets/
    /__better_errors/
    /sidekiq/
    /api/appears
  )
end
