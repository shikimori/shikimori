describe UsersController do
  let(:user) { create :user, password: '123' }
  before { sign_in user }

  describe 'settings' do
    describe 'json' do
      before { get :show, id: user.to_param, type: 'settings', page: 'account', format: :json }
      it { expect(response.content_type).to eq 'application/json' }
      it { should respond_with :success }
    end

    %w{account profile password styles list notifications misc}.each do |page|
      describe page do
        before { get :show, id: user.to_param, type: 'settings', page: page }
        it { should respond_with_content_type :html }
        it { should respond_with :success }
      end
    end
  end

  describe 'update_password' do
    context 'user without password' do
      before do
        user.update_column :encrypted_password, ''
        allow(controller).to receive(:current_user).and_return user
        patch :update_password, id: user.to_param, user: { password: '1234', password_confirmation: '1234' }
      end
      it { should redirect_to user_settings_path(user) }
    end

    context 'user with password' do
      context 'with correct password' do
        before { patch :update_password, id: user.to_param, user: { current_password: '123', password: '1234', password_confirmation: '1234' } }
        it { should redirect_to user_settings_path(user) }
      end

      context 'invalid password' do
        before { patch :update_password, id: user.to_param, user: { current_password: '1234', password: '1234', password_confirmation: '1234' } }
        it { should respond_with :success }
      end

      context 'no password' do
        before { patch :update_password, id: user.to_param, user: {} }
        it { should respond_with :success }
      end
    end

    context 'wrong user' do
      let(:user2) { create :user }
      before { patch :update_password, id: user2.to_param, user: { current_password: '123', password: '1234', password_confirmation: '1234' } }
      it { should respond_with :forbidden }
    end
  end

  describe 'update' do
    context 'wrong user' do
      let(:user2) { create :user }
      before { patch :update, id: user2.to_param }
      it { should respond_with :forbidden }
    end

    context 'nickname change' do
      before { patch :update, id: user.to_param, page: :account, user: { nickname: 'test2' } }
      it { should redirect_to user_settings_url('test2', page: :account) }
    end
  end
end
