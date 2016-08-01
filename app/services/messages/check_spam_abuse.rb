class Messages::CheckSpamAbuse < ServiceObjectBase
  include Translation
  pattr_initialize :message

  SPAM_LINKS = %r{
    cos30.ru/M=5j-N9 |
    aHR0cDovL3ByaW1hcnl4Lm5ldC9ncmVlaz9kbGM9a2ltb3Jp |
    goo.gl/KfKxKC |
    primaryx.net/quadro\?dlc=\w+
  }mix

  # rubocop:disable LineLength
  SPAM_PHRASES = [
    'Хорош качать уже) А то всё качаем,качаем',
    'Поднадоело читать, ищу напарника со мной в игру. Если за, то регайся и качай тут',
    'Вот прям затягивает и на моём ноуте идёт. Полно народу кстати бегает, регистрируйся'
  ]
  # rubocop:enable LineLength

  def call
    if spam?
      message.errors[:base] << ban_text
      Users::BanSpamAbuse.perform_async message.from_id
      false
    else
      true
    end
  end

private

  def spam?
    message.kind == MessageType::Private &&
      (
        message.body =~ SPAM_LINKS ||
        SPAM_PHRASES.any? { |phrase| message.body.include? phrase }
      )
  end

  def ban_text
    i18n_t :ban_text, email: Site::EMAIL, locale: message.from.locale
  end
end
