class Sendgrid < ActionMailer::Base
  default from: "mail@shikimori.org"
  default_url_options[:host] = 'shikimori.org'

  def test email = 'takandar@gmail.com'
    return if generated?(email)

    mail(to: email, subject: 'Test', body: 'test body')
  end

  def private_message_email message
    return if message.reload.read?
    return if generated?(message.to.email)

    mail(
      to: message.to.email,
      subject: "Личное сообщение",
      body: "#{message.to.nickname}, на ваш аккаунт на shikimori поступило личное сообщение от пользователя #{message.from.nickname}.
Прочитать можно тут #{messages_url :inbox}

Отписаться от получения уведомлений о личных сообщениях можно перейдя по ссылке #{messages_unsubscribe_url name: message.to.to_param, key: MessagesController::unsubscribe_key(message.to, MessageType::Private)}"
    )
  end

  def reset_password_instructions user, token, options
    @resource = user
    @token = token
    return if generated?(@resource.email)

    mail(to: @resource.email, subject: "Reset password instructions", tag: 'password-reset', content_type: "text/html") do |format|
      format.html { render "devise/mailer/reset_password_instructions" }
    end
  end

  def mail options, *args
    super
  rescue Postmark::InvalidMessageError => e
    User.find_by_email(options[:to]).notify_bounced_email
  end

private
  def generated? email
    !!(email.blank? || email =~ /^generated_/)
  end
end
