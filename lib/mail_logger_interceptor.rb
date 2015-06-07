class MailLoggerInterceptor
  def self.delivering_email mail
    return if mail.to.empty?

    # http://stackoverflow.com/a/18423438/3632318
    ::NamedLogger.email.info "TO: #{Array(mail.to).join ', '}
FROM: #{mail.from.join ', '}
SUBJECT: #{mail.subject}
BODY: #{mail.body.parts.first ? mail.body.parts.first.body.to_s : mail.body.to_s}"
  end
end
