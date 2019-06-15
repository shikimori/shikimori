describe Users::LockHacked do
  include_context :timecop

  let!(:banhammer) { create :user, :banhammer }
  let!(:original_password) { user.encrypted_password }

  subject! { Users::LockHacked.new.perform user.id }

  it do
    expect(user.reload.encrypted_password).to_not eq original_password
    expect(user.messages).to have(1).item
    expect(user.messages.first).to have_attributes(
      from: banhammer,
      to: user,
      kind: MessageType::PRIVATE,
      body: I18n.t(
        'users/check_hacked.lock_text',
        email: Shikimori::EMAIL,
        locale: user.locale.to_sym,
        recovery_url: UrlGenerator.instance.new_user_password_url(
          protocol: Shikimori::PROTOCOL
        )
      )
    )
  end
end
