describe UserRatesController do
  include_context :authenticated, :user

  describe '#index' do
    let!(:user_rate) { create :user_rate, user: user, target: anime }
    let(:anime) { create :anime, :ongoing }
    let(:make_request) do
      get :index,
        params: {
          profile_id: user.to_param,
          list_type: 'anime',
          order: 'ranked'
        }
    end

    context 'has access to list' do
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'has no access to list' do
      let(:user) do
        create :user,
          preferences: create(:user_preferences, list_privacy: :owner)
      end
      before { sign_out user }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#edit' do
    let(:user_rate) { create :user_rate, user: user }
    before { get :edit, params: { id: user_rate.id } }
    it { expect(response).to have_http_status :success }
  end
end
