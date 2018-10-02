describe Messages::CheckSpamAbuse do
  include_context :timecop

  before { allow(Users::BanSpamAbuse).to receive :perform_async }

  subject! { Messages::CheckSpamAbuse.call message }

  let(:message) { build :message, kind, from: user, body: text }
  let(:kind) { :private }
  let(:text) { 'cos30.ru/M=5j-N9' }

  context 'spam' do
    context 'link' do
      it do
        is_expected.to eq false
        expect(message.errors[:base]).to eq [I18n.t('messages/check_spam_abuse.ban_text', email: Shikimori::EMAIL)]
        expect(Users::BanSpamAbuse)
          .to have_received(:perform_async)
          .with message.from_id
      end
    end

    context 'phrase' do
      let(:text) { 'Хорош качать уже) А то всё качаем,качаем..' }
      it { is_expected.to eq false }
    end

    describe 'spam from guest' do
      let(:user) { create :user, :guest }

      it do
        is_expected.to eq false
        expect(message.errors[:base]).to eq ['spam']
        expect(Users::BanSpamAbuse).to_not have_received :perform_async
      end
    end
  end

  context 'not private message' do
    let(:kind) { :notification }

    it do
      is_expected.to eq true
      expect(message.errors[:base]).to be_empty
      expect(Users::BanSpamAbuse).to_not have_received :perform_async
    end
  end

  context 'not spam' do
    let(:text) { '' }

    it do
      is_expected.to eq true
      expect(message.errors[:base]).to be_empty
      expect(Users::BanSpamAbuse).to_not have_received :perform_async
    end
  end
end
