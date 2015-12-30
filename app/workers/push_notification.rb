class PushNotification
  include Sidekiq::Worker
  sidekiq_options queue: :push_notifications

  def perform message_id, device_id
    message = Message.find message_id
    device = Device.find device_id

    gcm.send_notification(
      [device.token],
      data: { message: gcm_message(message) }
    )
  end

private

  def gcm
    @gcm ||= GCM.new Rails.application.secrets.gcm[:token]
  end

  def gcm_message message
    {
      action: message.kind.to_underscore,
      msgTitle: nil,
      msgBody: message.body,
      params: {
        message_id: message.id,
        from: UserSerializer.new(message.from).attributes
      }
    }
  end
end
