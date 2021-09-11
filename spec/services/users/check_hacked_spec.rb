describe Users::CheckHacked do
  include_context :timecop

  before { allow(Users::LockHacked).to receive :perform_async }

  subject! do
    Users::CheckHacked.call(
      model: message,
      text: message.body,
      user: message.from
    )
  end

  let(:message) { build :message, kind, body: text }
  let(:kind) { :private }

  context 'spam' do
    let(:text) { 'https://shikme.ru/' }

    context 'link', :vcr do
      it do
        is_expected.to eq false
        expect(message.errors[:base]).to eq [
          I18n.t(
            'users/check_hacked.lock_text',
            email: Shikimori::EMAIL,
            locale: message.from.locale,
            recovery_url: UrlGenerator.instance.new_user_password_url(
              protocol: Shikimori::PROTOCOL
            )
          )
        ]
        expect(Users::LockHacked)
          .to have_received(:perform_async)
          .with message.from_id
      end
    end

    context 'link with forbidden response', :vcr do
      it do
        is_expected.to eq false
        expect(message.errors[:base]).to eq [
          I18n.t(
            'users/check_hacked.lock_text',
            email: Shikimori::EMAIL,
            locale: message.from.locale,
            recovery_url: UrlGenerator.instance.new_user_password_url(
              protocol: Shikimori::PROTOCOL
            )
          )
        ]
        expect(Users::LockHacked)
          .to have_received(:perform_async)
          .with message.from_id
      end
    end

    context 'spam link', :vcr do
      let(:text) { 'https://discord.gg/hVybUWQQGS' }
      it do
        is_expected.to eq false
        expect(Users::LockHacked)
          .to have_received(:perform_async)
          .with message.from_id
      end
    end
  end

  context 'not spam' do
    let(:text) { '' }

    it do
      is_expected.to eq true
      expect(message.errors[:base]).to be_empty
      expect(Users::LockHacked).to_not have_received :perform_async
    end

    context 'link from NOT_SPAM_DOMAINS list' do
      let(:text) { 'https://www.vk.com/test' }
      it { is_expected.to eq true }
    end
  end
end
