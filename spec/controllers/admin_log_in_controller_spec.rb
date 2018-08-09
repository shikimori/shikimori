describe AdminLogInController do
  before do
    Rails.env.stub(:production?).and_return true
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
  let(:target_user) { seed :user }

  describe '#restore' do
    before { sign_in target_user }

    context 'no saved admin in session' do
      subject! { get :restore }
      it { expect(response).to have_http_status 404 }
    end

    context 'saved admin in session' do
      before { session[AdminLogInController.admin_id_to_restore_key] = user_admin.id }
      subject! { get :restore }

      it do
        expect(session[AdminLogInController.admin_id_to_restore_key]).to be_nil
        expect(assigns(:user).id).to eq user_admin.id
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#log_in' do
    context 'admin' do
      include_context :authenticated, :admin
      subject! { get :log_in, params: { nickname: nickname } }
      let(:nickname) { target_user.nickname }

      context 'known user' do
        it do
          expect(assigns(:user).id).to eq target_user.id
          expect(session[AdminLogInController.admin_id_to_restore_key]).to eq user_admin.id
          expect(response).to redirect_to root_path
        end
      end

      context 'unknown user' do
        let(:nickname) { 'zzzzzzzz' }
        it { expect(response).to have_http_status 422 }
      end
    end

    context 'user' do
      include_context :authenticated, :user
      subject! { get :log_in, params: { nickname: target_user.nickname } }

      it do
        expect(session[AdminLogInController.admin_id_to_restore_key]).to be_nil
        expect(response).to have_http_status 404
      end
    end
  end
end
