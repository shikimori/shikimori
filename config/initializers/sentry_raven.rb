if defined? Raven
  Raven.configure do |config|
    config.dsn = 'https://722c6c94e0304d5f82a7e5213244475d:2616aa4cd01c4c5180b9dd1d6b48dd6f@sentry.io/217873'
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
