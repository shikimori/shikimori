describe EmailNotifier do
  include_context :timecop

  let(:service) { described_class.instance }
  let(:message) { build_stubbed :message, to: target_user, from: from_user }
  let(:from_user) { seed :user }
  let(:target_user) do
    build_stubbed :user,
      notification_settings: notification_settings,
      last_online_at: last_online_at
  end
  let(:last_online_at) { Time.zone.now }

  describe '#private_message' do
    let(:mailer_double) { double private_message_email: nil }

    before do
      allow(ShikiMailer).to receive(:delay_for).and_return mailer_double
      stub_const 'EmailNotifier::DAILY_USER_EMAILS_LIMIT', 1
    end
    let!(:present_message) { nil }

    subject! { service.private_message message }

    context 'target user allowed private emails' do
      let(:notification_settings) { [:private_message_email] }

      it { expect(mailer_double).to have_received(:private_message_email).with(message.id) }

      context 'target user is online' do
        let(:last_online_at) { Time.zone.now - User::LAST_ONLINE_CACHE_INTERVAL + 1.second }
        it { expect(ShikiMailer).to have_received(:delay_for).with(EmailNotifier::ONLINE_USER_MESSAGE_DELAY) }
      end

      context 'taget user is not online' do
        let(:last_online_at) { Time.zone.now - User::LAST_ONLINE_CACHE_INTERVAL - 1.second }
        it { expect(ShikiMailer).to have_received(:delay_for).with(EmailNotifier::OFFLINE_USER_MESSAGE_DELAY) }
      end

      context 'messages limit' do
        let!(:present_message) { create :message, :with_send_email, :private, from: from_user }
        it { expect(mailer_double).to_not have_received :private_message_email }

        context 'another user messages' do
          let!(:present_message) { create :message, :with_send_email, :private, from: build_stubbed(:user) }
          it { expect(mailer_double).to have_received :private_message_email }
        end

        context 'not private message' do
          let!(:present_message) { create :message, :with_send_email, :notification, from: from_user }
          it { expect(mailer_double).to have_received :private_message_email }
        end
      end
    end

    context 'target user did not allow private emails' do
      let(:notification_settings) { [:my_ongoing] }
      it { expect(ShikiMailer).to_not have_received(:delay_for) }
    end
  end
end
