class MailLoggerInterceptor
  def self.delivering_email mail # rubocop:disable Metrics/AbcSize
    return if mail.to.empty?

    body =
      if mail.body.parts.first
        mail.body.parts.first.body.to_s
      else
        mail.body.to_s
      end

    # http://stackoverflow.com/a/18423438/3632318
    ::NamedLogger.email.info <<~TEXT
      TO: #{Array(mail.to).join ', '}
      FROM: #{mail.from.join ', '}
      SUBJECT: #{mail.subject}
      BODY: #{body}
    TEXT
  end
end

ActionMailer::Base.register_interceptor ::MailLoggerInterceptor
