require 'exception_notification/rails'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  config.ignored_exceptions += %w{NotFound Unauthorized Forbidden}
  #config.ignore_crawlers += %w{bingbot} #Googlebot

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
   config.ignore_if do |exception, options|
     not Rails.env.production?
   end

  # Notifiers =================================================================

  config.add_notifier :email,
    sender_address: %{"ExceptionNotification" <exceptions@shikimori.org>},
    exception_recipients: %w{takandar@gmail.com},
    delivery_method: :smtp
    #email_prefix: "[shikimori] ",

  # Email notifier sends notifications by email.
  #config.add_notifier :email, {
    #:email_prefix         => "[ERROR] ",
    #:sender_address       => %{"Notifier" <notifier@example.com>},
    #:exception_recipients => %w{exceptions@example.com}
  #}

  # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
  # config.add_notifier :campfire, {
  #   :subdomain => 'my_subdomain',
  #   :token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # Webhook notifier sends notifications over HTTP protocol. Requires 'httparty' gem.
  # config.add_notifier :webhook, {
  #   :url => 'http://example.com:5555/hubot/path',
  #   :http_method => :post
  # }
end
