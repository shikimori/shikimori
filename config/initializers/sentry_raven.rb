# if defined? Raven
#   Raven.configure do |config|
#     config.dsn = 'https://49ff8cc56e5c4d0fad6c80a87c977c49:bd503c6e7ba94fd2b1069ffb18c42d86@sentry.io/4384681'
#     config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
#     config.environments = %w[production]
#     config.ssl_verification = false
#
#     Shikimori::IGNORED_EXCEPTIONS
#       .map { |v| v.constantize rescue NameError }
#       .reject { |v| v == NameError }
#       .each do |klass|
#         config.excluded_exceptions << klass.name
#       end
#   end
# end

if defined? Sentry
  Sentry.init do |config|
    config.dsn = 'https://2a1ac3c28b4b432e81919a1efb6559a8@o99341.ingest.sentry.io/6757810'
    config.environment = 'production'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.excluded_exceptions << klass.name
      end

    config.traces_sample_rate = 1.0
  end
end
