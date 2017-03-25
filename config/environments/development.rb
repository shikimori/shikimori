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
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    # config.cache_store = :memory_store
    config.cache_store = :dalli_store, 'localhost', {
      namespace: 'shikimori_development',
      compress: true,
      value_max_bytes: 1024 * 1024 * 128
    }
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  Dalli.logger = ActiveSupport::Logger.new(STDOUT)

  # config.middleware.use TurboDev
  config.middleware.use I18n::JS::Middleware

  # # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # config.active_record.logger = ActiveSupport::Logger.new('log/sql.log')

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true
  config.assets.debug = false

  config.assets.raise_production_errors = true
  config.assets.raise_runtime_errors = true
  config.assets.logger = ActiveSupport::Logger.new('log/assets.log')

  # if defined? ActiveRecordQueryTrace
    # ActiveRecordQueryTrace.enabled = true
  # end

  #if defined? Rails::Console
    #ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
    ###ActiveRecord::Base.logger.level = 3
    ##ActiveRecord::Base.logger.level = 1
    #ActiveSupport::Cache::Store.logger = Logger.new(STDOUT)
    #Dalli.logger = Logger.new(STDOUT)
  #end


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Flog.configure do |config|
    # # If this value is true, not format on cached query
    # config.ignore_cached_query = false
    # # If query duration is under this value, not format
    # config.query_duration_threshold = 8.0
    # # If key count of parameters is under this value, not format
    # config.params_key_count_threshold = 4
    # # If this value is true, nested Hash parameter is formatted coercively in any situation
    # config.force_on_nested_params = false
  # end
end
