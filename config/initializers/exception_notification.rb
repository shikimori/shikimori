require 'exception_notification/rails'
require 'exception_notification/sidekiq'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  config.ignored_exceptions += %w{NotFound Unauthorized Forbidden}
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  config.ignore_if do |exception, options|
    not Rails.env.production?
  end

  config.add_notifier :email,
    sender_address: %{"ExceptionNotification" <exceptions@shikimori.org>},
    exception_recipients: %w{takandar@gmail.com},
    delivery_method: :smtp
end
