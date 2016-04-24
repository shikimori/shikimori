class Messages::CheckSpamAbuse < ServiceObjectBase
  include Translation
  pattr_initialize :message

  SPAM = %r{
    cos30.ru/M=5j-N9 |
    aHR0cDovL3ByaW1hcnl4Lm5ldC9ncmVlaz9kbGM9a2ltb3Jp |
    PrimaryX.NET/greek?dlc=Kimori |
    goo.gl/KfKxKC
  }mix

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
    message.kind == MessageType::Private && message.body =~ SPAM
  end

  def ban_text
    i18n_t :ban_text, email: Site::EMAIL, locale: locale
  end

  def locale
    message.from.russian? ? :ru : :en
  end
end
