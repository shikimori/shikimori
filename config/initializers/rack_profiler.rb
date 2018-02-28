# if Rails.env.development?
#   require 'rack-mini-profiler'
#   require 'flamegraph'

#   # initialization is skipped so trigger it
#   Rack::MiniProfilerRails.initialize! Rails.application
#   Rack::MiniProfiler.config.position = 'right'
#   Rack::MiniProfiler.config.skip_paths = %w(
#     /spnsrs/
#     /assets/
#     /__better_errors/
#     /sidekiq/
#     /api/appears
#   )
# end
