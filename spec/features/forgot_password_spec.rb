feature 'forgot_password' do
  feature 'first step' do
    scenario 'when success' do
      expect(user.reload.reset_password_token).to be_nil

      forgot_password user

      expect(user.reload.reset_password_token).to_not be_nil
      expect(current_path).to eq new_user_session_path
    end

    scenario 'when fail' do
      user.email = '123'
      forgot_password user

      expect(user.reload.reset_password_token).to be_nil
      expect(current_path).to eq user_password_path
      expect(page).to have_selector '.menu-icon.sign_in'
    end
  end

  feature 'second step' do
    let(:tokens) { Devise.token_generator.generate User, :reset_password_token }
    let(:public_token) { tokens[0] }
    let(:private_token) { tokens[1] }

    let!(:initial_password) { user.encrypted_password }

    let(:user) do
      create :user,
        reset_password_token: private_token,
        reset_password_sent_at: Time.zone.now
    end

    scenario 'when success' do
      restore_password user, public_token

      expect(user.reload.encrypted_password).to_not eq initial_password
      # expect(current_path).to eq new_project_path
      expect(current_path).to eq root_path
    end

    scenario 'when fail' do
      restore_password user, public_token + '1'

      expect(user.reload.reset_password_token).to_not be_nil
      expect(current_path).to eq user_password_path
      expect(page).to have_selector '.menu-icon.sign_in'
    end
  end
end
