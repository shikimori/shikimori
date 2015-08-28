describe Moderation::VersionsController do
  include_context :back_redirect
  include_context :authenticated, :versions_moderator

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
    describe 'html' do
      before { get :index }
      it { expect(response).to have_http_status :success }
    end

    describe 'json' do
      before { get :index, page: 2, format: :json }
      it { expect(response).to have_http_status :success }
    end
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

  describe '#accept_taken' do
    let(:version) { create :description_version, :taken, item: anime, item_diff: { russian: ['a', 'bbb'] }, user: author }
    before { post :accept_taken, id: version.id }

    it do
      expect(resource).to be_accepted
      expect(response).to redirect_to back_url
    end
  end

  describe '#take_accepted' do
    let(:version) { create :description_version, :accepted, item: anime, item_diff: { russian: ['a', 'bbb'] }, user: author }
    before { post :take_accepted, id: version.id }

    it do
      expect(resource).to be_taken
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

  describe '#create' do
    let(:make_request) { post :create, version: params }
    let(:params) {{
      item_id: anime.id,
      item_type: Anime.name,
      item_diff: changes,
      user_id: user.id,
      reason: 'test'
    }}
    let(:role) { :user }

    describe 'common user' do
      include_context :authenticated, :user

      context 'common change' do
        before { make_request }
        let(:changes) {{ 'russian' => ['fofofo', 'zxcvbnn'] }}

        it do
          expect(resource).to be_persisted
          expect(resource).to have_attributes params
          expect(resource).to be_pending
          expect(response).to redirect_to back_url
        end
      end

      context 'significant change' do
        let(:changes) {{ 'name' => ['fofofo', 'zxcvbnn'] }}
        it { expect{make_request}.to raise_error CanCan::AccessDenied }
      end
    end

    describe 'moderator' do
      include_context :authenticated, :versions_moderator
      let(:changes) {{ 'russian' => [nil, 'zxcvbnn'] }}
      before { make_request }

      it do
        expect(resource).to be_persisted
        expect(resource).to have_attributes params
        expect(resource).to be_accepted
        expect(response).to redirect_to back_url
      end
    end
  end
end
