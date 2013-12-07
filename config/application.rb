require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Site
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/app/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # load fonts assets
    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Europe/Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :ru
    config.i18n.locale = :ru

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.middleware.use 'Redirecter'# if Rails.env.production?
    config.middleware.insert_before 0, 'ProxyTest'
    Paperclip.logger.level = 2

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += [ Proc.new { |path| !%w(.js .css).include?(File.extname(path)) }, /.*.(css|js)$/ ]

    config.action_mailer.default_url_options = { host: 'www.shikimori.org' }
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_key: open("#{ENV['HOME']}/shikimori.org/postmark.key").read.strip }

    config.action_mailer.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: 'shikimori.org',
      user_name: 'mail@shikimori.org',
      password: open("#{ENV['HOME']}/shikimori.org/mail@shikimori.org").read.strip,
      authentication: 'plain',
      enable_starttls_auto: true
    }

    config.generators do |g|
      g.template_engine :slim
      g.stylesheets     false
      g.helper          false
      g.helper_specs    false
      g.view_specs      false
    end
  end
end
