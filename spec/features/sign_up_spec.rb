feature 'sign up' do
  let(:user) { build :user, nickname: "test#{(rand * 1_000_000).to_i}", password: '123456' }
  let(:created_user) { User.find_by nickname: user.nickname }

  context 'when success' do
    scenario 'registration' do
      expect { sign_up user }.to change(User, :count).by 1

      expect(page).to_not have_selector '#sign_in'
      expect(current_path).to eq root_path
    end
  end

  scenario 'when fail' do
    user.password = ''
    sign_up user

    expect(page).to have_selector '#sign_in'
    expect(current_path).to_not eq new_user_session_path
  end
end
