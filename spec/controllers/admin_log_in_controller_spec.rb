describe AdminLogInController do
  before { Rails.env.stub(:production?).and_return true }
  before { @request.env["devise.mapping"] = Devise.mappings[:user] }
  let(:admin) { create :user, :admin }
  let(:user) { create :user, :user }

  describe '#restore' do
    before { sign_in user }

    context 'no saved admin in session' do
      before { get :restore }
      it { should respond_with :not_found }
    end

    context 'saved admin in session' do
      before { session[AdminLogInController.admin_id_to_restore_key] = admin.id }
      before { get :restore }

      it { expect(session[AdminLogInController.admin_id_to_restore_key]).to be_nil }
      it { expect(assigns(:user).id).to eq admin.id }
      it { expect(response).to redirect_to root_url }
    end
  end

  describe '#log_in' do
    context 'admin' do
      before { sign_in admin }
      before { get :log_in, nickname: nickname }
      let(:nickname) { user.nickname }

      context 'known user' do
        it { expect(assigns(:user).id).to eq user.id }
        it { expect(session[AdminLogInController.admin_id_to_restore_key]).to eq admin.id }
        it { expect(response).to redirect_to root_url }
      end

      context 'unknown user' do
        let(:nickname) { 'zzzzzzzz' }
        it { expect(response).to have_http_status 422 }
      end
    end

    context 'user' do
      before { sign_in user }
      before { get :log_in, nickname: user.nickname }

      it { should respond_with :not_found }
      it { expect(session[AdminLogInController.admin_id_to_restore_key]).to be_nil }
    end
  end
end
