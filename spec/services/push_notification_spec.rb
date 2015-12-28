describe PushNotification do
  let(:service) { PushNotification.new message, device }

  let(:message) { build :message, :profile_commented, from: from, to: to }
  let(:from) { build_stubbed :user, id: 1, name: 'user_1' }
  let(:to) { build_stubbed :user, id: 2, name: 'user_2' }
  let(:device) { build :device }

  describe '#perform' do
    let(:gcm) { service.send :gcm }
    let(:gcm_message) {{
      action: 'profile_commented',
      msgTitle: from.nickname,
      msgBody: "Написал что-то в вашем <a class='b-link' \
href='http://test.host/#{to.nickname}'>профиле</a>..."
    }}

    before { allow(gcm).to receive :send_notification }
    before { service.call }

    it do
      expect(gcm).to have_received(:send_notification)
        .with [device.token], data: { message: gcm_message }
    end
  end
end
