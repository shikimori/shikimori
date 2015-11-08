describe EmailNotifier do
  before { Timecop.freeze }
  before { Timecop.return }

  let(:notifier) { EmailNotifier.instance }
  let(:message) { build_stubbed :message, to: target_user }
  let(:target_user) { build_stubbed :user, notifications: notifications, last_online_at: last_online_at }
  let(:last_online_at) { Time.zone.now }

  describe '#private_message' do
    let(:mailer_double) { double private_message_email: nil }

    before { allow(ShikiMailer).to receive(:perform_in).and_return mailer_double }
    before { notifier.private_message message }

    context 'target user allowed private emails' do
      let(:notifications) { User::PRIVATE_MESSAGES_TO_EMAIL }

      it { expect(mailer_double).to have_received(:private_message_email).with(message) }

      context 'target user is online' do
        let(:last_online_at) { Time.zone.now - User::LAST_ONLINE_CACHE_INTERVAL + 1.second }
        it { expect(ShikiMailer).to have_received(:perform_in).with(EmailNotifier::ONLINE_USER_MESSAGE_DELAY) }
      end

      context 'taget user is not online' do
        let(:last_online_at) { Time.zone.now - User::LAST_ONLINE_CACHE_INTERVAL - 1.second }
        it { expect(ShikiMailer).to have_received(:perform_in).with(EmailNotifier::OFFLINE_USER_MESSAGE_DELAY) }
      end
    end

    context 'target user did not allow private emails' do
      let(:notifications) { 0 }
      it { expect(ShikiMailer).to_not have_received(:perform_in) }
    end
  end
end
