describe ShikiMailer do
  describe '#private_message_email' do
    subject(:mail) { ShikiMailer.private_message_email(message).deliver_now }

    let(:unsubscribe_link_key) { '123' }
    before do
      allow_any_instance_of(ShikiMailer)
        .to receive(:unsubscribe_link_key)
        .and_return unsubscribe_link_key
    end

    let(:from_user) { create :user, nickname: 'Randy' }
    let(:to_email) { 'test@gmail.com' }
    let(:to_user) { create :user, nickname: 'Vasya', email: to_email }
    let(:read) { false }
    let(:message_body) { 'Hi, Vasya!' }
    let(:message) do
      create :message,
        read: read,
        to: to_user,
        from: from_user,
        body: message_body
    end

    it do
      expect(mail.subject).to eq(
        I18n.t('shiki_mailer.private_message_email.subject')
      )
      expect(mail.body.raw_source).to eq "
        #{to_user.nickname}, у вас 1 новое сообщение на shikimori.org от пользователя #{from_user.nickname}.
        Прочитать полностью можно тут: http://test.host/#{to_user.nickname}/dialogs

        Текст сообщения:
        #{message_body}

        Отписаться от уведомлений можно по ссылке:
        http://test.host/messages/#{to_user.nickname}/#{unsubscribe_link_key}/Private/unsubscribe
      ".gsub(/^ +/, '').strip
    end

    context 'message is read' do
      let(:read) { true }
      it { is_expected.to be_nil }
    end

    context 'with generated email' do
      let(:to_email) { 'generated_123@mail.ru' }
      it { is_expected.to be_nil }
    end
  end

  describe '#reset_password_instructions' do
    subject(:mail) do
      ShikiMailer.reset_password_instructions(
        user,
        token,
        nil
      ).deliver_now
    end

    let(:email) { 'test@gmail.com' }
    let(:user) { build :user, nickname: 'Vasya', email: email }
    let(:token) { 'token' }

    it do
      expect(mail.subject).to eq(
        I18n.t('shiki_mailer.reset_password_instructions.subject')
      )
      expect(mail.body.raw_source).to eq "
        Привет!

        Кто-то активировал процедуру сброса пароля для вашего аккаунта на shikimori.org.

        Изменить пароль можно, перейдя по данной ссылке: http://test.host/users/password/edit?reset_password_token=#{token}

        Если вы не запрашивали сброс пароля, то просто проигнорируйте это письмо.

        Ваш пароль не будет изменён до тех пор, пока вы не перейдёте по указанной выше ссылке.
      ".gsub(/^ +/, '').strip
    end

    context 'with generated email' do
      let(:email) { 'generated_123@mail.ru' }
      it { is_expected.to be_nil }
    end
  end
end
