class PushNotification < ServiceObjectBase
  pattr_initialize :message, :device

  def call
    gcm.send_notification(
      [device.token],
      data: { message: gcm_message }
    )
  end

private

  def gcm
    @gcm ||= GCM.new Rails.application.secrets.gcm[:token]
  end

  def decorated_message
    @decorated_message ||= message.decorate
  end

  def gcm_message
    {
      action: message.kind.to_underscore,
      msgTitle: decorated_message.title,
      msgBody: decorated_message.generate_body
      # params: { param: true }
    }
  end
end
