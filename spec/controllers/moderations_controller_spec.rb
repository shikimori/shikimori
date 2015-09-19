describe ModerationsController do
  describe '#show' do
    context 'guest' do
      before { get :show }
      it { expect(response).to redirect_to new_user_session_url }
    end

    context 'authenticated' do
      include_context :authenticated, :user
      before { get :show }
      it { expect(response).to be_success }
    end
  end

  describe '#missing_videos' do
    include_context :authenticated, :user

    describe 'no kind' do
      before { get :missing_videos }
      it { expect(response).to be_success }
    end

    describe 'all' do
      before { get :missing_videos, kind: :all }
      it { expect(response).to be_success }
    end
  end
end
