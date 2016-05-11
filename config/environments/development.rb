Site::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  config.cache_store = :dalli_store, 'localhost', {
    namespace: 'shikimori_development',
    compress: true,
    value_max_bytes: 1024 * 1024 * 128
  }

  # Expands the lines which load the assets
  #config.assets.debug = true
  config.assets.debug = false
  config.assets.raise_production_errors = true
  config.assets.raise_runtime_errors = true
  config.assets.logger = ActiveSupport::Logger.new('log/assets.log')

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :letter_opener

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  config.middleware.use 'TurboDev'
  config.middleware.use 'I18n::JS::Middleware'

  if defined? Pry
    Pry.config.auto_indent = false
    Pry.config.editor = 'mvim'
  end

  # config.active_record.logger = ActiveSupport::Logger.new('log/sql.log')

  #if defined? Rails::Console
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    ###ActiveRecord::Base.logger.level = 3
    ##ActiveRecord::Base.logger.level = 1
    #ActiveSupport::Cache::Store.logger = Logger.new(STDOUT)
    #Dalli.logger = Logger.new(STDOUT)
  #end

  Slim::Engine.set_options pretty: false

  # ActiveRecordQueryTrace.enabled = true

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

  # if defined? BetterErrors
    # BetterErrors::Middleware.allow_ip! '127.0.0.1'
    # BetterErrors.editor = :macvim
    # BetterErrors.use_pry!
  # end
end
