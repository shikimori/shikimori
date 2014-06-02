require 'spec_helper'

feature 'forgot_password' do#, troublesome: true do
  pending "надо написать"
  feature 'first step' do
    let(:user) { create :user }

    #scenario 'when success' do
      #forgot_password user
      #expect(user.reload.reset_password_token).to_not be_nil
      #expect(current_path).to eq new_user_session_path
    #end

    #scenario 'when fail' do
      #user.email = '123'
      #forgot_password user

      #expect(user.reload.reset_password_token).to be_nil
      #expect(current_path).to eq user_password_path
      #expect(page).to have_selector '.field_with_errors'
    #end
  end

  feature 'second step' do
    let(:tokens) { Devise.token_generator.generate User, :reset_password_token }
    let(:public_token) { tokens[0] }
    let(:private_token) { tokens[1] }
    let(:user) { create :user, reset_password_token: private_token, reset_password_sent_at: Time.zone.now }

    let!(:site) { create :site, user: user }

    #scenario 'when success' do
      #restore_password user, public_token

      #expect(user.reload.reset_password_token).to eq public_token
      #expect(current_path).to eq site_path(site)
    #end

    #scenario 'when fail' do
      #restore_password user, public_token+'1'

      #expect(user.reload.reset_password_token).to_not be_nil
      #expect(current_path).to eq user_password_path
      #expect(page).to have_selector '.field_with_errors'
    #end
  end
end
