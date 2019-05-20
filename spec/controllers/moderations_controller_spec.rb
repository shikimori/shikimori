describe ModerationsController do
  describe '#show' do
    context 'guest' do
      before { get :show }
      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :show }
      it { expect(response).to have_http_status :success }
    end
  end
end
