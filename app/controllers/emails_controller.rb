class EmailsController < ShikimoriController
  skip_before_action :verify_authenticity_token

  def bounce
    NamedLogger.bounce.info email
    user = User.find_by email: email

    if user.present? && email.present?
      Messages::CreateNotification.new(user).bad_email
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
      notification_settings: user.notification_settings.values -
        [Types::User::NotificationSettings[:private_message_email].to_s]
    )
  end
end
