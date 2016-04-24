describe Messages::CheckSpamAbuse do
  before { Timecop.freeze }
  after { Timecop.return }

  before { allow(Users::BanSpamAbuse).to receive :perform_async }

  subject! { Messages::CheckSpamAbuse.call message }

  let(:message) { build :message, kind, body: body }
  let(:kind) { :private }
  let(:body) { 'cos30.ru/M=5j-N9' }

  context 'spam' do
    it { is_expected.to eq false }
    it { expect(message.errors[:base]).to eq [I18n.t('messages/check_spam_abuse.ban_text', email: Site::EMAIL)] }
    it { expect(Users::BanSpamAbuse).to have_received(:perform_async).with message.from_id }
  end

  context 'not private message' do
    let(:kind) { :notification }

    it { is_expected.to eq true }
    it { expect(message.errors[:base]).to be_empty }
    it { expect(Users::BanSpamAbuse).to_not have_received :perform_async }
  end

  context 'not spam' do
    let(:body) { '' }

    it { is_expected.to eq true }
    it { expect(message.errors[:base]).to be_empty }
    it { expect(Users::BanSpamAbuse).to_not have_received :perform_async }
  end
end
