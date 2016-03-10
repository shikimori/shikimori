if defined? Rack::MiniProfiler
  Rack::MiniProfiler.config.skip_paths = %w(
    /sponsors/
    /assets/
  )
end
