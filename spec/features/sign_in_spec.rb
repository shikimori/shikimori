feature 'sign in' do#, troublesome: true do
  let(:user) { create :user, email: "test#{rand}@gmail.com", password: '123456' }

  pending "надо написать"
  #scenario 'when success' do
    #sign_in user

    #expect(page).to_not have_selector '.l-landing'
    #expect(current_path).to eq site_path(site)
  #end

  #scenario 'when fail' do
    #user.email = user.email+'z'
    #sign_in user

    #expect(page).to have_selector '.l-landing'
    #expect(current_path).to eq new_user_session_path
  #end
end
