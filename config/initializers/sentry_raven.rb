Raven.configure do |config|
  config.dsn = 'https://722c6c94e0304d5f82a7e5213244475d:2616aa4cd01c4c5180b9dd1d6b48dd6f@sentry.io/217873'
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.excluded_exceptions += %w[
    CanCan::AccessDenied
    ActionController::InvalidAuthenticityToken
    ActionController::UnknownFormat
    ActionDispatch::RemoteIp::IpSpoofAttackError
    ActiveRecord::RecordNotFound
    I18n::InvalidLocale
    Unicorn::ClientShutdown
    Unauthorized
    AgeRestricted
    MismatchedEntries
    CopyrightedResource
    Net::SMTPServerBusy
    Net::SMTPFatalError
    Interrupt
    Apipie::ParamMissing
    InvalidIdError
    InvalidParameterError
    EmptyContentError
    MalParser::RecordNotFound
    BadImageError
    Errors::NotIdentifiedByImageMagickError
  ]
  config.environments = %w[production]
  config.ssl_verification = false
end if defined?(Raven)
