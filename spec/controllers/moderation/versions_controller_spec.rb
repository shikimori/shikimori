describe Moderation::VersionsController do
  include_context :back_redirect
  include_context :authenticated, :user_changes_moderator

  let(:version) { create :version, item: anime, item_diff: { russian: ['a', 'bbb'] }, state: state, user: author }
  let(:author) { user }
  let(:state) { 'pending' }
  let(:anime) { create :anime }

  describe '#show' do
    before { get :show, id: version.id }
    it { expect(response).to have_http_status :success }
  end

  describe '#tooltip' do
    before { get :tooltip, id: version.id }
    it { expect(response).to have_http_status :success }
  end

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    before { post :accept, id: version.id }

    it do
      expect(resource).to be_accepted
      expect(response).to redirect_to back_url
    end
  end

  describe '#take' do
    before { post :take, id: version.id }

    it do
      expect(resource).to be_taken
      expect(response).to redirect_to back_url
    end
  end

  describe '#reject' do
    before { post :reject, id: version.id, reason: 'test' }

    it do
      expect(resource).to be_rejected
      expect(response).to redirect_to back_url
    end
  end

  describe '#destroy' do
    let(:make_request) { delete :destroy, id: version.id }

    context 'moderator' do
      before { make_request }
      it do
        expect(resource).to be_deleted
        expect(response).to redirect_to back_url
      end
    end

    context 'author' do
      include_context :authenticated, :user
      before { make_request }

      it do
        expect(resource).to be_deleted
        expect(response).to redirect_to back_url
      end
    end

    context 'user' do
      include_context :authenticated, :user
      let(:author) { create :user, :user }

      it do
        expect{make_request}.to raise_error CanCan::AccessDenied
        expect(resource).to be_pending
      end
    end
  end
end
