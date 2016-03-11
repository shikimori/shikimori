if defined? Rack::MiniProfiler
  Rack::MiniProfiler.config.skip_paths = %w(
    /sponsors/
    /assets/
    /__better_errors/
    /sidekiq/
  )
end
