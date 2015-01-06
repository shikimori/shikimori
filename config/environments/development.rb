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
  config.assets.debug = true
  config.assets.raise_production_errors = true

  # Don't care if the mailer can't send
  #config.action_mailer.asset_host = 'http://dev.shikimori.org'
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :letter_opener

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  if defined? Pry
    Pry.config.auto_indent = false
    Pry.config.editor = 'mvim'
  end

  #if defined? Rails::Console
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    ##ActiveRecord::Base.logger.level = 1
    #ActiveSupport::Cache::Store.logger = Logger.new(STDOUT)
    #Dalli.logger = Logger.new(STDOUT)
  #end

  if defined? SqlLogging
    SqlLogging::Statistics.show_top_sql_queries = false
    SqlLogging::Statistics.show_sql_backtrace = false
  end

  Slim::Engine.set_default_options pretty: false

  #if defined? BetterErrors
    #BetterErrors::Middleware.allow_ip! '127.0.0.1'
    #BetterErrors.editor = :macvim
    #BetterErrors.use_pry!
  #end
end
