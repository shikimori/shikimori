# важно указывать протокол в урла, т.к. по дефолту он выключен, а письма
# отсылаются в plain text
class ShikiMailer < ActionMailer::Base
  include Routing
  include Translation

  default from: "noreply@#{Site::DOMAIN}"

  def test_mail email = 'takandar@gmail.com'
    return if generated?(email)
    mail(to: email, subject: 'Test', body: 'test body')
  end

  def private_message_email message
    return if message.reload.read?
    return if generated?(message.to.email)

    mail(
      to: message.to.email,
      subject: i18n_t('private_message_email.subject'),
      body: i18n_t(
        'private_message_email.body',
        nickname: message.to.nickname,
        site_link: Site::DOMAIN,
        from_nickname: message.from.nickname,
        private_message_link: profile_dialogs_url(message.to, protocol: :http),
        message: message.body,
        unsubscribe_link: unsubscribe_messages_url(
          name: message.to.to_param,
          key: unsubscribe_link_key(message),
          protocol: :http
        )
      )
    )
  end

  def reset_password_instructions user, token, options
    return if generated?(user.email)
    @resource = user
    @token = token

    mail(
      to: @resource.email,
      subject: i18n_t('reset_password_instructions.subject'),
      tag: 'password-reset',
      body: i18n_t(
        'reset_password_instructions.body',
        site_link: Site::DOMAIN,
        reset_password_link: edit_user_password_url(
          reset_password_token: @token,
          protocol: :http
        )
      )
    )
  end

  #def mail options, *args
    #super
  #rescue Postmark::InvalidMessageError => e
    #User.find_by_email(options[:to]).notify_bounced_email
  #end

private

  def unsubscribe_link_key message
    MessagesController::unsubscribe_key message.to, MessageType::Private
  end

  def generated? email
    !!(email.blank? || email =~ /^generated_/)
  end
end
