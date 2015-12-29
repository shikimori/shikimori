describe PushNotification do
  let(:worker) { PushNotification.new }

  let(:message) { create :message, :profile_commented }
  let(:device) { create :device }

  describe '#perform' do
    let(:gcm) { worker.send :gcm }
    let(:gcm_message) { worker.send :gcm_message, message }

    before { allow(gcm).to receive :send_notification }
    before { worker.perform message.id, device.id }

    it do
      expect(gcm).to have_received(:send_notification)
        .with [device.token], data: { message: gcm_message }
    end
  end
end
