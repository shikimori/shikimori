describe ShikiMailer do
  describe '#private_message_email' do
    subject(:mail) { ShikiMailer.private_message_email(message).deliver_now }

    let(:read) { false }
    let(:to_email) { 'test@gmail.com' }
    let(:to_user) { create :user, email: to_email }
    let(:message) { create :message, read: read, to: to_user }

    it do
      expect(mail.subject).to eq(
        I18n.t('shiki_mailer.private_message_email.subject')
      )
      expect(mail.body.raw_source).to eq "
        user_2, у вас 1 новое сообщение на shikimori.org от пользователя user_1.
        Прочитать полностью можно тут: http://test.host/user_2/dialogs

        Текст сообщения: test

        Отписаться от уведомлений можно по ссылке http://test.host/messages/user_2/ec166bfdca4e59d3ce2e209a76c548d6f3685a3d/Private/unsubscribe
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
    let(:user) { build :user, email: email }
    let(:token) { 'token' }

    it do
      expect(mail.subject).to eq(
        I18n.t('shiki_mailer.reset_password_instructions.subject')
      )
      expect(mail.body.raw_source).to eq "
        Привет!

        Кто-то активировал процедуру сброса пароля для вашего аккаунта на <a href=\"http://shikimori.org\">shikimori.org</a>.

        Изменить пароль можно, перейдя по <a href=\"http://test.host/users/password/edit.user_2?reset_password_token=token\">ссылке</a>.

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
