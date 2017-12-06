describe EmailNotifier do
  include_context :timecop

  let(:notifier) { EmailNotifier.instance }
  let(:message) { build_stubbed :message, to: target_user, from: from_user }
  let(:from_user) { seed :user }
  let(:target_user) { build_stubbed :user, notifications: notifications, last_online_at: last_online_at }
  let(:last_online_at) { Time.zone.now }

  describe '#private_message' do
    let(:mailer_double) { double private_message_email: nil }

    before do
      allow(ShikiMailer).to receive(:delay_for).and_return mailer_double
      stub_const 'EmailNotifier::DAILY_USER_EMAILS_LIMIT', 1
    end
    let!(:present_message) {}
    subject! { notifier.private_message message }

    context 'target user allowed private emails' do
      let(:notifications) { User::PRIVATE_MESSAGES_TO_EMAIL }

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
        let!(:present_message) { create :message, :private, from: from_user }
        it { expect(mailer_double).to_not have_received :private_message_email }

        context 'another user messages' do
          let!(:present_message) { create :message, :private, from: build_stubbed(:user) }
          it { expect(mailer_double).to have_received :private_message_email }
        end

        context 'not private message' do
          let!(:present_message) { create :message, :notification, from: from_user }
          it { expect(mailer_double).to have_received :private_message_email }
        end
      end
    end

    context 'target user did not allow private emails' do
      let(:notifications) { 0 }
      it { expect(ShikiMailer).to_not have_received(:delay_for) }
    end
  end
end
