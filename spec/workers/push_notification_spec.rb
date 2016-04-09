describe PushNotification do
  let(:worker) { PushNotification.new }

  let(:message) { create :message, :profile_commented, read: is_read }
  let(:device) { create :device }

  describe '#perform' do
    let(:gcm) { worker.send :gcm }
    let(:gcm_message) do
      {
        action: 'profile_commented',
        msgTitle: nil,
        msgBody: 'Написал что-то в вашем профиле.',
        params: {
          message_id: message.id,
          from: UserSerializer.new(message.from).attributes
        }
      }
    end

    before { allow(gcm).to receive :send_notification }
    before { worker.perform message.id, device.id }

    context 'not read message' do
      let(:is_read) { false }
      it do
        expect(gcm).to have_received(:send_notification)
          .with [device.token], data: { message: gcm_message }
      end
    end

    context 'read message' do
      let(:is_read) { true }
      it { expect(gcm).to_not have_received :send_notification }
    end
  end
end
