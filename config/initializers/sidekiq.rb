SidekiqUniqueJobs::Config.unique_args_enabled = true
SidekiqUniqueJobs::Config.default_expiration = 2.days

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq::Logging.logger
  config.poll_interval = 5

  config.redis = { url: "redis://localhost:6379/#{Rails.application.config.redis_db}" }
  #config.redis = { namespace: "shiki_#{Rails.env}" } unless Rails.env.development?
end

#class Sidekiq::Extensions::DelayedMailer::ExceptionHandling
module Sidekiq::Extensions::PostmarkHandler
  def perform yml
    super

  rescue Postmark::InvalidMessageError => e
    target, method_name, args = YAML.load yml
    case method_name.to_sym
      when :private_message_email then args.first.to.notify_bounced_email
      when :reset_password_instructions then args.first.notify_bounced_email
      else raise
    end
  end
end

Sidekiq::Extensions::DelayedMailer.send :prepend, Sidekiq::Extensions::PostmarkHandler
