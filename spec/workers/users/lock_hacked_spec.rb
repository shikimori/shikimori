describe Users::LockHacked do
  include_context :timecop

  let(:user) { seed :user }
  let!(:banhammer) { create :user, id: User::BANHAMMER_ID }
  let!(:original_password) { user.encrypted_password }
  let!(:original_api_access_token) { user.api_access_token }

  subject! { Users::LockHacked.new.perform user.id }

  it do
    expect(user.reload.encrypted_password).to_not eq original_password
    expect(user.api_access_token).to_not eq original_api_access_token
    expect(user.messages).to have(1).item
    expect(user.messages.first).to have_attributes(
      from: banhammer,
      to: user,
      kind: MessageType::Private,
      body: I18n.t(
        'messages/check_hacked.lock_text',
        email: Shikimori::EMAIL,
        locale: user.locale,
        recovery_url: UrlGenerator.instance.new_user_password_url(
          protocol: Shikimori::ALLOWED_PROTOCOL
        )
      )
    )
  end
end
