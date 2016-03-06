if defined? Rack::MiniProfiler
  Rack::MiniProfiler.config.skip_paths = [
    '/sponsors/'
  ]
end
