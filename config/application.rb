require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Site
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/app/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Europe/Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ru
    config.i18n.locale = :ru
    I18n.enforce_available_locales = true

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.middleware.use 'Redirecter' unless Rails.env.development?
    config.middleware.insert_before 0, 'ProxyTest'
    config.middleware.use 'Rack::JSONP'
    Paperclip.logger.level = 2

    # Enable the asset pipeline
    config.assets.enabled = true
    # load fonts assets
    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    ActiveRecord::Base.include_root_in_json = false
    #config.active_record.disable_implicit_join_references = true
    config.active_record.raise_in_transactional_callbacks = true

    config.redis_db = 2

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += [ Proc.new { |path| !%w(.js .css).include?(File.extname(path)) }, /.*.(css|js)$/ ]

    config.action_mailer.default_url_options = { host: 'shikimori.org' }
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_key: Rails.application.secrets.postmark[:api_key] }

    config.action_mailer.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: 'shikimori.org',
      user_name: Rails.application.secrets.smtp[:login],
      password: Rails.application.secrets.smtp[:password],
      authentication: 'plain',
      enable_starttls_auto: true
    }

    config.generators do |g|
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.template_engine :slim
      g.stylesheets false
      g.helperfalse
      g.helper_specs false
      g.view_specs false
      g.test_framework :rspec
    end
  end
end
