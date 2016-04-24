class EmailsController < ShikimoriController
  def bounce
    NamedLogger.bounce.info email
    user = User.find_by email: email

    if user.present? && email.present?
      Message.create_wo_antispam!(
        from_id: BotsService.get_poster.id,
        to_id: user.id,
        kind: MessageType::Notification,
        body: "Наш почтовый сервис не смог доставить письмо на вашу почту #{user.email}.\nВы либо указали несуществующий почтовый ящик, либо когда-то пометили одно из наших писем как спам. Рекомендуем сменить e-mail в настройках профиля, иначе при утере пароля вы не сможете восстановить свой аккаунт."
      )
      shush! user
    end

    head 200
  end

  def spam
    NamedLogger.spam.info email
    user = User.find_by email: email

    if user.present? && email.present?
      shush! user
    end

    head 200
  end

private

  def email
    params[:recipient]
  end

  def shush! user
    user.update_columns(
      email: '',
      notifications: user.notifications - User::PRIVATE_MESSAGES_TO_EMAIL
    )
  end
end
