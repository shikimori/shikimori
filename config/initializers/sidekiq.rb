# https://github.com/mperham/sidekiq/issues/750
require 'sidekiq/middleware/i18n'
require 'sidekiq/web'

Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
Sidekiq::Web.set :sessions, Rails.application.config.session_options

ENV['REDIS_NAMESPACE_QUIET'] = 'true' # Disable deprecation warning

# The Delayed Extensions delay, delay_in and delay_until APIs are no longer
# available by default. The extensions allow you to marshal job
# arguments as YAML, leading to cases where job payloads could be many 100s
# of KB or larger if not careful, leading to Redis networking timeouts or
# other problems. As noted in the Best Practices wiki page,
# Sidekiq is designed for jobs with small, simple arguments.
# Add this line to your initializer to re-enable them and get the old behavior:
Sidekiq::Extensions.enable_delay!

REDIS_OPTIONS = {
  namespace: "shiki_#{Rails.env}",
  url: "redis://#{Rails.application.config.redis_host}:6379/#{Rails.application.config.redis_db}"
}
Sidekiq.configure_client do |config|
  config.redis = REDIS_OPTIONS
end

class ChewyMiddleware
  def initialize options = nil
  end

  def call worker, msg, queue
    Chewy.strategy(:atomic) { yield }
  end
end

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq::Logging.logger
  config.average_scheduled_poll_interval = 5

  config.redis = REDIS_OPTIONS
  # config.error_handlers << Proc.new {|e,ctx_hash| NamedLogger.send("#{Rails.env}_errors").error "#{e.message}\n#{ctx_hash.to_json}\n#{e.backtrace.join("\n")}" }

  config.server_middleware do |chain|
    chain.add ChewyMiddleware
  end
end

if Rails.env.development? && Time.zone.today < Time.zone.parse('2021-06-01')
  Redis.exists_returns_integer =  true
end
