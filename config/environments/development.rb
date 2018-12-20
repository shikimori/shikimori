Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    # config.cache_store = :memory_store
    config.cache_store = :mem_cache_store, 'localhost', {
      namespace: 'shikimori_development',
      compress: true,
      value_max_bytes: 1024 * 1024 * 128
    }
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  if Shikimori::PROTOCOL == 'https'
    config.force_ssl = true
    config.ssl_options = {
      hsts: { preload: true, subdomains: true, expires: 3.years }
    }
  end

  # Dalli.logger = Rails.logger

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  config.middleware.use I18n::JS::Middleware

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :letter_opener

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  Flog.configure do |config|
    # If this value is true, not format on cached query
    config.ignore_cached_query = false
    # If query duration is under this value, not format
    config.query_duration_threshold = 8.0
    # If key count of parameters is under this value, not format
    config.params_key_count_threshold = 4
    # If this value is true, nested Hash parameter is formatted coercively in any situation
    config.force_on_nested_params = false
  end
end
