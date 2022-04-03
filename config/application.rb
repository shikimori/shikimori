require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/shikimori_domain'
require_relative '../lib/string'
require_relative '../lib/responders/json_responder'
require_relative '../lib/named_logger'
require_relative '../lib/log_before_timeout'

unless Rails.env.test?
  Dir['config/middleware/*'].each { |file| require_relative "../#{file}" }
end

module Shikimori
  DOMAINS = {
    production: 'shikimori.one',
    development: 'shikimori.local',
    test: 'shikimori.test'
  }
  DOMAIN = DOMAINS[Rails.env.to_sym]

  NAME_RU = 'Шикимори'
  NAME_EN = 'Shikimori'

  STATIC_SUBDOMAINS = %w[nyaa kawai moe desu dere]
  EMAIL = 'mail@shikimori.org'
  EMAIL_DATA_DELETION = 'mail+data_deletion@shikimori.org'

  DOMAIN_LOCALES = %i[ru en]

  ALLOWED_DOMAINS = ShikimoriDomain::RU_HOSTS + ShikimoriDomain::EN_HOSTS

  VK_CLUB_URL = 'https://vk.com/shikimori'
  DISCORD_CHANNEL_URL = 'https://discord.gg/fQrr2ms'

  PROTOCOLS = {
    production: 'https',
    development: 'http',
    test: 'http'
  }
  PROTOCOL = PROTOCOLS[Rails.env.to_sym]

  LOCAL_RUN = ENV['LOGNAME'] == 'morr' && ENV['USER'] == 'morr'
  # ALLOWED_PROTOCOL = Rails.env.production? && !LOCAL_RUN ? 'https' : 'http'

  IGNORED_EXCEPTIONS = %w[
    AbstractController::ActionNotFound
    ActionController::InvalidAuthenticityToken
    ActionController::ParameterMissing
    ActionController::RoutingError
    ActionController::UnknownFormat
    ActionController::UnknownHttpMethod
    ActionController::BadRequest
    ActionDispatch::RemoteIp::IpSpoofAttackError
    ActiveRecord::PreparedStatementCacheExpired
    ActiveRecord::RecordNotFound
    CanCan::AccessDenied
    I18n::InvalidLocale
    Unicorn::ClientShutdown
    Unauthorized
    AgeRestricted
    MismatchedEntries
    InvalidEpisodesError
    CopyrightedResource
    Net::SMTPServerBusy
    Net::SMTPFatalError
    Interrupt
    Apipie::ParamMissing
    InvalidIdError
    InvalidParameterError
    EmptyContentError
    MalParser::RecordNotFound
    Errors::NotIdentifiedByImageMagickError
    Sidekiq::Shutdown
    Terrapin::ExitStatusError
  ]

  IS_SUMMARIES_ENABLED = !Rails.env.production?
  IS_IMAGEBOARD_TAGS_ENABLED = false
  IS_RECAPTCHA_V3 = false

  class Application < Rails::Application
    def redis
      Rails.application.config.redis
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    # This option is not backwards compatible with earlier Rails versions.
    # It's best enabled when your entire app is migrated and stable on 6.0.
    # NOTE: enabling it logouts all users from their accounts
    config.action_dispatch.use_cookies_with_metadata = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += Dir["#{config.root}/app/models"]
    # config.autoload_paths += Dir["#{config.root}/app/**/"]
    # config.paths.add 'lib', eager_load: true

    config.autoload_paths << "#{config.root}/app/*"
    config.autoload_paths << "#{Rails.root}/lib"
    config.eager_load_paths << "#{Rails.root}/lib"

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Europe/Moscow'

    I18n.enforce_available_locales = true

    config.i18n.default_locale = :ru
    config.i18n.locale = :ru
    config.i18n.available_locales = %i[ru en]
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml')]

    # Configure sensitive parameters which will be filtered from the log file.
    # RAILS 6.0 UPGRADE
    # config.filter_parameters += [:password]
    Paperclip.logger.level = 2

    # Enable the asset pipeline
    # RAILS 6.0 UPGRADE
    # config.assets.enabled = true

    # RAILS 6.0 UPGRADE
    # ActiveRecord::Base.include_root_in_json = false

    # RAILS 6.0 UPGRADE
    # config.active_record.cache_versioning = true

    config.redis_host = 'localhost'
    config.redis_db = 2

    # достали эксепшены с ханибаджера
    # config.action_dispatch.ip_spoofing_check = false

    config.action_dispatch.trusted_proxies = %w(
      139.162.130.157
      84.201.128.45
      145.239.87.191
      185.62.190.16
      88.198.7.123
      159.69.114.227
      135.181.210.175
    ).map do |proxy|
      IPAddr.new proxy
    end

    config.action_mailer.default_url_options = {
      host: Shikimori::DOMAIN
    }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: 'smtp.eu.mailgun.org',
      port: 587,
      user_name: Rails.application.secrets.mailgun[:login],
      password: Rails.application.secrets.mailgun[:password],
      domain: Shikimori::DOMAIN
    }

    #config.action_mailer.smtp_settings = {
      #address: "smtp.gmail.com",
      #port: 587,
      #domain: Shikimori::DOMAIN,
      #user_name: Rails.application.secrets.smtp[:login],
      #password: Rails.application.secrets.smtp[:password],
      #authentication: 'plain',
      #enable_starttls_auto: true
    #}

    config.generators do |generator|
      generator.fixture_replacement :factory_bot, dir: 'spec/factories/'
      generator.template_engine :slim
      generator.stylesheets false
      generator.helper false
      generator.helper_specs false
      generator.view_specs false
      generator.test_framework :rspec
    end

    config.redis = Redis.new(
      host: Rails.application.config.redis_host,
      port: 6379
    )
  end
end
