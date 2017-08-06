# https://github.com/mperham/sidekiq/issues/750
require 'sidekiq/middleware/i18n'

# The Delayed Extensions delay, delay_in and delay_until APIs are no longer
# available by default. The extensions allow you to marshal job
# arguments as YAML, leading to cases where job payloads could be many 100s
# of KB or larger if not careful, leading to Redis networking timeouts or
# other problems. As noted in the Best Practices wiki page,
# Sidekiq is designed for jobs with small, simple arguments.
# Add this line to your initializer to re-enable them and get the old behavior:
Sidekiq::Extensions.enable_delay!

if defined? Sidekiq::Web
  domain = ShikimoriDomain::RU_HOSTS[Rails.env.production? ? 0 : 1]
  Sidekiq::Web.set :sessions, domain: ".#{domain}"
  # Sidekiq::Web.set :sessions, domain: 'all'
  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
end

SidekiqUniqueJobs.config.unique_args_enabled = true
SidekiqUniqueJobs.config.default_expiration = 30.days

Sidekiq.configure_client do |config|
  config.redis = { namespace: "shiki_#{Rails.env}", url: "redis://localhost:6379/#{Rails.application.config.redis_db}" }
end

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq::Logging.logger
  config.average_scheduled_poll_interval = 5

  config.redis = { namespace: "shiki_#{Rails.env}", url: "redis://localhost:6379/#{Rails.application.config.redis_db}" }
  config.error_handlers << Proc.new {|e,ctx_hash| NamedLogger.send("#{Rails.env}_errors").error "#{e.message}\n#{ctx_hash.to_json}\n#{e.backtrace.join("\n")}" }
end

#module Sidekiq::Extensions::PostmarkHandler
  #def perform yml
    #super

  #rescue Postmark::InvalidMessageError => e
    #target, method_name, args = YAML.load yml
    #case method_name.to_sym
      #when :private_message_email then args.first.to.notify_bounced_email
      #when :reset_password_instructions then args.first.notify_bounced_email
      #else raise
    #end
  #end
#end

#Sidekiq::Extensions::DelayedMailer.send :prepend, Sidekiq::Extensions::PostmarkHandler
