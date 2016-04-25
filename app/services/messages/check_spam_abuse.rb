class Messages::CheckSpamAbuse < ServiceObjectBase
  include Translation
  pattr_initialize :message

  SPAM_LINKS = %r{
    cos30.ru/M=5j-N9 |
    aHR0cDovL3ByaW1hcnl4Lm5ldC9ncmVlaz9kbGM9a2ltb3Jp |
    PrimaryX.NET/greek?dlc=Kimori |
    goo.gl/KfKxKC
  }mix

  SPAM_PHRASES = %r{
    Хорош \s качать \s уже\) \s А \s то \s всё \s качаем,качаем
  }mx

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
      (message.body =~ SPAM_LINKS || message.body =~ SPAM_PHRASES)
  end

  def ban_text
    i18n_t :ban_text, email: Site::EMAIL, locale: locale
  end

  def locale
    message.from.russian? ? :ru : :en
  end
end
