require 'spec_helper'

feature 'sign up' do#, troublesome: true do
  let(:user) { build :user, email: "test#{rand}@gmail.com", password: '123456' }

  pending "надо написать"
  #scenario 'when success' do
    #expect { sign_up user }.to change(User, :count).by 1

    #expect(page).to_not have_selector '.l-landing'
    #expect(current_path).to eq root_path
    #expect(page).to_not have_selector '.field_with_errors'
  #end

  #scenario 'when fail' do
    #user.password = 'zz'
    #sign_up user

    #expect(page).to have_selector '.field_with_errors'
  #end
end
