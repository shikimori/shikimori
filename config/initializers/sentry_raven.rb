if defined? Sentry
  Sentry.init do |config|
    config.dsn = 'https://2a1ac3c28b4b432e81919a1efb6559a8@o99341.ingest.sentry.io/6757810'
    # config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    # config.environments = %w[production]
    # config.ssl_verification = false

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.excluded_exceptions << klass.name
      end

    # config.traces_sample_rate = 1.0
    # # or
    # config.traces_sampler = lambda do |context|
    #   true
    # end
  end
end
