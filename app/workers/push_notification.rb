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
  rescue *Network::FaradayGet::NET_ERRORS
  end

private

  def gcm
    @gcm ||= GCM.new Rails.application.secrets.gcm[:token]
  end

  def gcm_message message
    message = message.decorate

    {
      action: message.kind.to_underscore,
      msgTitle: nil,
      msgBody: generate_body(message),
      params: {
        message_id: message.id,
        from: UserSerializer.new(message.from).attributes
      }
    }
  end

  def generate_body message
    body = Retryable.retryable tries: 2, on: TypeError, sleep: 1 do
      message.generate_body.gsub(/<.*?>/, '')
    end

    if body.size > 199
      body[0..198] + '…'
    else
      body
    end
  end
end
