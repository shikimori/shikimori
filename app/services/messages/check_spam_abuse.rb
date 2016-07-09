class Messages::CheckSpamAbuse < ServiceObjectBase
  include Translation
  pattr_initialize :message

  SPAM_LINKS = %r{
    cos30.ru/M=5j-N9 |
    aHR0cDovL3ByaW1hcnl4Lm5ldC9ncmVlaz9kbGM9a2ltb3Jp |
    PrimaryX.NET/greek\?dlc=Kimori |
    goo.gl/KfKxKC |
    primaryx.net/quadro\?dlc=kimori
  }mix

  SPAM_PHRASES = [
    /
        Хорош \s качать \s уже\) \s А \s то \s всё \s качаем,качаем
    /mix,
    /
      Поднадоело \s читать, \s ищу \s напарника \s со \s мной \s в \s игру. \s
      Если \s за, \s то \s регайся \s и \s качай \s тут
    /mix
  ]

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
        SPAM_PHRASES.any? { |v| v =~ message.body }
      )
  end

  def ban_text
    i18n_t :ban_text, email: Site::EMAIL, locale: message.from.locale
  end
end
