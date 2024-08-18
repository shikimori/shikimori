require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SecretsDeprecationWarningSilencer
  def secrets
    @secrets ||= begin
      secrets = ActiveSupport::OrderedOptions.new
      files = config.paths["config/secrets"].existent
      files = files.reject { |path| path.end_with?(".enc") } unless config.read_encrypted_secrets
      secrets.merge! Rails::Secrets.parse(files, env: Rails.env)

      # Fallback to config.secret_key_base if secrets.secret_key_base isn't set
      secrets.secret_key_base ||= config.secret_key_base

      secrets
    end
  end
end
Rails::Application.send :prepend, SecretsDeprecationWarningSilencer

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

  PROTOCOLS = {
    production: 'https',
    development: 'http',
    test: 'http'
  }
  PROTOCOL = ENV['IS_LOCAL_RUN'] ? 'http' : PROTOCOLS[Rails.env.to_sym]

  HOST = "#{Shikimori::PROTOCOL}://#{Shikimori::DOMAIN}"

  NAME_RU = 'Шикимори'
  NAME_EN = 'Shikimori'

  STATIC_SUBDOMAINS = %w[desu]
  # STATIC_SUBDOMAINS = %w[nyaa kawai moe desu dere]
  EMAIL = 'admin@shikimori.me'
  # EMAIL_DATA_DELETION = 'mail+data_deletion@shikimori.org'

  DOMAIN_LOCALES = %i[ru en]

  ALLOWED_DOMAINS = ShikimoriDomain::HOSTS

  VK_CLUB_URL = 'https://vk.com/shikimori'
  DISCORD_CHANNEL_URL = 'https://discord.gg/gYQNpUKPdH'


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
    AgeRestricted
    RknBanned
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
  IS_TURNSTILE = true

  class Application < Rails::Application
    def redis
      Rails.application.config.redis
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    config.active_support.cache_format_version = 7.1
    config.active_record.marshalling_format_version = 6.1

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

    config.autoload_lib(ignore: %w(assets tasks))

    # config.autoload_paths << "#{config.root}/app/*"
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

    config.active_job.queue_adapter = :sidekiq

    # Configure sensitive parameters which will be filtered from the log file.
    # RAILS 6.0 UPGRADE
    # config.filter_parameters += [:password]
    Paperclip.logger.level = 2

    if defined?(Redirecter) && !ENV['IS_LOCAL_RUN'] # not defined for clockwork
      config.middleware.use Redirecter
    end

    config.middleware.insert 0, Rack::UTF8Sanitizer
    if defined?(ProxyTest) # not defined for clockwork
      config.middleware.insert 0, ProxyTest
    end

    config.middleware.use Rack::Attack
    # config.middleware.use LogBeforeTimeout

    config.middleware.insert_before 0, Rack::Cors do
      if Rails.env.development?
        allow do
          origins '*'
          resource '*', headers: :any, methods: %i[get options post put patch]
        end
      else
        allow do
          origins do |source, env|
            ALLOWED_DOMAINS.include?(Url.new(source).domain.to_s) &&
              Url.new(source).protocol.to_s == PROTOCOL
          end
          resource '*', headers: :any, methods: %i[get options]
        end

        allow do
          origins '*'
          resource '/comments/smileys', headers: :any, methods: %i[get options]
        end

        allow do
          origins '*'
          resource '/api/*', headers: :any, methods: %i[get options post put patch delete]
          resource '/oauth/token', headers: :any, methods: %i[post]
        end
      end
    end

    # fixes numerous errors on production
    config.active_record.yaml_column_permitted_classes = [Time]

    config.redis_host = ENV['REDIS_HOST'] ? ENV['REDIS_HOST'] : 'localhost'
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

    config.action_controller.default_url_options = {
      host: Shikimori::DOMAIN,
      port: nil
    }
    config.action_mailer.default_url_options = {
      host: Shikimori::DOMAIN,
      port: nil
    }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: 'smtp.eu.mailgun.org',
      port: 587,
      user_name: Rails.application.secrets.mailgun[:login],
      password: Rails.application.secrets.mailgun[:password],
      domain: Shikimori::DOMAINS[:production]
    }

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
