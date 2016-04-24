describe Users::BanSpamAbuse do
  before { Timecop.freeze }
  after { Timecop.return }

  let(:user) { seed :user }

  before { Users::BanSpamAbuse.new.perform user.id }

  describe '#perform' do
    it do
      expect(user.reload.read_only_at).to eq Users::BanSpamAbuse::BAN_DURATION.from_now
      expect(user.messages).to have(1).item
      expect(user.messages.first).to have_attributes(
        to: user,
        kind: MessageType::Notification,
        body: I18n.t('messages/check_spam_abuse.ban_text', email: Site::EMAIL)
      )
    end
  end
end
