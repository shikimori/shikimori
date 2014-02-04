Site::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Turn off logging colors
  config.colorize_logging = false

  # Do eager load code on boot.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  #config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  #config.assets.precompile += %w( admin.css email.css registrations.css standart.css admin.js application_new.js application_new.css *.js admin/*.css)

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :warn

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  config.cache_store = :dalli_store, 'localhost', {
    namespace: 'shikimori_production',
    compress: true,
    value_max_bytes: 1024 * 1024 * 16
  }

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  if defined?(Pry)
    Pry.config.auto_indent = false
    Pry.config.editor = 'mvim'
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.exception_recipients = %w{takandar@gmail.com}
  config.notify_exceptions = true
end
