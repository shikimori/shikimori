# https://github.com/mperham/sidekiq/issues/750
require 'sidekiq/middleware/i18n'

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
