SidekiqUniqueJobs::Config.unique_args_enabled = true
SidekiqUniqueJobs::Config.default_expiration = 2.days

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq::Logging.logger
  config.poll_interval = 5
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

Sidekiq.configure_server do |config|
  config.redis = { namespace: "shiki_#{Rails.env}" } unless Rails.env.development?
end
