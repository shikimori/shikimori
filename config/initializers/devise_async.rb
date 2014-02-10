Devise::Async.setup do |config|
  config.enabled = true
  config.backend = :sidekiq
  config.queue   = :critical
end

module Devise::Async::Backend::PostmarkHandler
  def perform method, resource_class, resource_id, *args
    super
  rescue Postmark::InvalidMessageError => e
    resource_class
      .constantize
      .find(resource_id)
      .notify_bounced_email
  end
end

Devise::Async::Backend::Sidekiq.send :prepend, Devise::Async::Backend::PostmarkHandler
