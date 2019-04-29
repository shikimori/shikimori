feature 'sign up' do
  let(:user) { build :user, nickname: 'test+zxc123@gmail.com', password: '123456' }
  let(:created_user) { User.find_by nickname: user.nickname }

  before do
    allow_any_instance_of(User).to receive :grab_avatar
    allow_any_instance_of(User).to receive :add_to_index
  end

  scenario 'when success', :vcr do
    expect { sign_up user }.to change(User, :count).by 1

    expect(page).to_not have_selector '.menu-icon.sign_in'
    expect(current_path).to eq root_path
  end

  scenario 'when fail' do
    user.password = ''
    sign_up user

    expect(page).to have_selector '.menu-icon.sign_in'
    expect(current_path).to_not eq new_user_session_path
  end
end
