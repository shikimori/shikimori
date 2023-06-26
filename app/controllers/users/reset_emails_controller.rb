class Users::ResetEmailsController < ProfilesController
  before_action :check_access!

  EMAIL_SUBJECT = 'Shikimori привязка почты к аккаунту'
  EMAIL_BODY = <<-TEXT.gsub(/^ +/, '')
    Привет!
    К Шикимори аккаунту %<user_url>s привязана твоя почта %<email>s.
    Теперь для восстановления доступа к аккаунту можно воспользоваться процедурой сброса пароля %<password_recovery_url>s.
  TEXT

  def new
  end

  def create # rubocop:disable  Metrics/MethodLength, Metrics/AbcSize
    if create_params[:email] == @resource.email
      @error = 'Емайл такой же, какой уже привязан к аккаунту.'
      return render :new
    end

    email_from = @resource.email
    if @resource.update email: create_params[:email]
      if create_params[:message].present?
        @message_body = format create_params[:message],
          user_url: @resource.url,
          email: @resource.email,
          password_recovery_url: new_user_password_url(user: { email: @resource.email })

        @mail = ShikiMailer
          .custom_message(
            email: @resource.email,
            subject: EMAIL_SUBJECT,
            body: @message_body
          )
          .deliver_now
      end
      NamedLogger.reset_email.info(
        moderator_id: current_user.id,
        user_id: @resource.id,
        email: {
          from: email_from,
          to: @resource.email
        },
        message: @message_body
      )

      render :success
    else
      @error = @resource.errors.full_messages.join('<br>').html_safe
      @resource.reload
      render :new
    end
  end

private

  def create_params
    params
      .require(:reset_email)
      .permit(:email, :message)
      .tap do |permitted_params|
        permitted_params[:email] = permitted_params[:email].strip
      end
  end

  def set_breadcrumbs
    super
    og page_title: 'Изменение почты'
    breadcrumb 'Модерация', moderation_profile_url(@resource)
  end

  def check_access!
    authorize! :reset_email, @resource
  end
end
