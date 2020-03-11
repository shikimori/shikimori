if defined? Raven
  Raven.configure do |config|
    config.dsn = 'https://49ff8cc56e5c4d0fad6c80a87c977c49:bd503c6e7ba94fd2b1069ffb18c42d86@sentry.io/4384681'
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.environments = %w[production]
    config.ssl_verification = false

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.excluded_exceptions << klass.name
      end
  end
end
