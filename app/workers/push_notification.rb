class PushNotification
  include Sidekiq::Worker
  sidekiq_options queue: :push_notifications

  def perform message_id, device_id
    message = Message.find_by id: message_id
    device = Device.find_by id: device_id

    return unless message && device

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
      action: message.kind.camelize.to_underscore,
      msgTitle: nil,
      msgBody: message.body,
      params: {
        message_id: message.id,
        from: UserSerializer.new(message.from).attributes
      }
    }
  end
end
