feature 'sign in' do
  let(:user) { create :user, nickname: "test#{(rand * 1_000_000).to_i}", password: '123456' }

  scenario 'when success' do
    sign_in user
    expect(current_path).to eq root_path
  end

  scenario 'when fail' do
    user.nickname = user.nickname + 'z'
    sign_in user
    expect(page).to have_selector '.menu-icon.sign_in'
    expect(current_path).to eq new_user_session_path
  end
end
