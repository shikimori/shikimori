describe PushNotification do
  let(:worker) { PushNotification.new }

  let(:message) { create :message, :profile_commented, read: is_read }
  let(:device) { create :device }

  describe '#perform' do
    let(:gcm) { worker.send :gcm }
    let(:gcm_message) { worker.send :gcm_message, message }

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
