describe UserHistoryController do
  let!(:user) { create :user }

  describe '#index' do
    context 'without history' do
      before { get :index, profile_id: user.to_param }
      it { should redirect_to profile_url(user) }
    end

    context 'with history' do
      let!(:history) { create :user_history, user: user, target: create(:anime) }
      let(:make_request) { get :index, profile_id: user.to_param }

      context 'has access to list' do
        before { make_request }
        it { should respond_with :success }
      end

      context 'has no access to list' do
        let(:user) { create :user, preferences: create(:user_preferences, profile_privacy: :owner) }
        before { sign_out user }
        it { expect{make_request}.to raise_error CanCan::AccessDenied }
      end
    end
  end

  describe '#reset' do
    let!(:user_history) { create :user_history, user: user, target: entry }
    let(:type) { entry.class.name.downcase }
    let(:make_request) { delete :reset, profile_id: user.to_param, type: type }

    context 'has no access' do
      let(:entry) { create :anime }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end

    context 'has access' do
      before { sign_in user }

      context 'anime' do
        let(:entry) { create :anime }
        before { make_request }

        it { should respond_with :success }
        it { expect(user.history).to be_empty }
      end

      context 'manga' do
        let(:entry) { create :manga }
        before { make_request }

        it { should respond_with :success }
        it { expect(user.history).to be_empty }
      end
    end
  end
end
