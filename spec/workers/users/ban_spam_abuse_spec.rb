describe Users::BanSpamAbuse do
  include_context :timecop

  let!(:banhammer) { create :user, id: User::BANHAMMER_ID }

  subject! { Users::BanSpamAbuse.new.perform user.id }

  it do
    expect(user.reload.read_only_at.to_i).to eq(
      Users::BanSpamAbuse::BAN_DURATION.from_now.to_i
    )
    expect(user.messages).to have(1).item
    expect(user.messages.first).to have_attributes(
      from: banhammer,
      to: user,
      kind: MessageType::PRIVATE,
      body: I18n.t('messages/check_spam_abuse.ban_text', email: Shikimori::EMAIL)
    )
  end
end
