# важно указывать протокол в урла, т.к. по дефолту он выключен, а письма
# отсылаются в plain text
class ShikiMailer < ActionMailer::Base
  include Routing
  include Translation

  default from: "noreply@#{Site::DOMAIN}"

  def test_mail email = 'takandar@gmail.com'
    return if generated? email

    mail to: email, subject: 'Test', body: 'test body'
  end

  def private_message_email message_id
    message = Message.find_by id: message_id

    return unless message
    return if message.read?
    return if generated? message.to.email

    subject = i18n_t(
      'private_message_email.subject',
      locale: message.to.locale
    )
    body = i18n_t(
      'private_message_email.body',
      nickname: message.to.nickname,
      site_link: Site::DOMAIN,
      from_nickname: message.from.nickname,
      private_message_link: profile_dialogs_url(message.to, protocol: :https),
      message: message.body,
      unsubscribe_link: unsubscribe_messages_url(
        name: message.to.to_param,
        key: unsubscribe_link_key(message),
        protocol: :https
      ),
      locale: message.to.locale
    )

    mail to: message.to.email, subject: subject, body: body
  end

  def reset_password_instructions user, token, options
    return if generated? user.email
    @resource = user
    @token = token

    subject = i18n_t(
      'reset_password_instructions.subject',
      locale: user.locale
    )
    body = i18n_t(
      'reset_password_instructions.body',
      site_link: Site::DOMAIN,
      nickname: user.nickname,
      reset_password_link: edit_user_password_url(
        reset_password_token: @token,
        protocol: :https
      ),
      locale: user.locale
    )

    mail(
      to: @resource.email,
      subject: subject,
      tag: 'password-reset',
      body: body
    )

  rescue Net::SMTPSyntaxError
    NamedLogger.email.info "failed to send email to #{Array(mail.to).join ', '}"
  end

  #def mail options, *args
    #super
  #rescue Postmark::InvalidMessageError => e
    #User.find_by_email(options[:to]).notify_bounced_email
  #end

private

  def unsubscribe_link_key message
    MessagesController.unsubscribe_key message.to, MessageType::Private
  end

  def generated? email
    !!(email.blank? || email =~ /^generated_/)
  end
end
