describe AdminLogInController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let (:user) { create :user, nickname: 'zxcxcbvvc' }

  describe 'GET restore' do
    before { sign_in create(:user) }

    context 'no saved admin in session' do
      it 'not found' do
        get :restore
        expect(response).to be_not_found
      end
    end

    context 'saved admin in session' do
      before { session[AdminLogInController.admin_id_to_restore_key] = user.id }

      it 'deletes admin id from session' do
        get :restore
        expect(session[AdminLogInController.admin_id_to_restore_key]).to be_nil
      end

      it 'restores user' do
        get :restore
        expect(assigns(:user).id).to eq user.id
      end

      it 'redirects to root' do
        get :restore
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET log_in' do
    context 'admin' do
      before do
        @admin = create :user, id: 1
        sign_in @admin
      end

      it 'changes current_user' do
        get :log_in, nickname: user.nickname
        expect(assigns(:user).id).to eq user.id
      end

      it 'saves admin id in session' do
        get :log_in, nickname: user.nickname
        expect(session[AdminLogInController.admin_id_to_restore_key]).to eq @admin.id
      end

      it 'redirects to root' do
        get :log_in, nickname: user.nickname
        expect(response).to redirect_to(root_url)
      end

      it 'shows 503 for unknown user' do
        get :log_in, nickname: 'zzzzzzzzzzzzzzzzz'
        expect(response).to be_unprocessible_entiy
      end
    end

    context 'user' do
      before { sign_in create(:user) }
      end

      it 'not found' do
        get :log_in, nickname: user.nickname
        expect(response).to be_not_found
      end

      it 'session is not set' do
        get :log_in, nickname: user.nickname
        expect(session[AdminLogInController.admin_id_to_restore_key]).to be_nil
      end
    end
  end
end
