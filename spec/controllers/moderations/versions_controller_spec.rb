describe Moderations::VersionsController do
  include_context :back_redirect
  include_context :authenticated, :version_texts_moderator

  let(:version) do
    create :version,
      item: anime,
      item_diff: { russian: ['a', 'bbb'] },
      state: state,
      user: author
  end
  let(:author) { user }
  let(:state) { 'pending' }
  let(:anime) { create :anime }

  describe '#index' do
    describe 'html' do
      before { get :index, params: { type: 'content' } }
      it { expect(response).to have_http_status :success }
    end

    describe 'json' do
      before { get :index, params: { type: 'content', page: 2 }, format: :json }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#show' do
    describe 'html' do
      before { get :show, params: { id: version.id } }
      it { expect(response).to have_http_status :success }
    end

    describe 'json' do
      before { get :show, params: { id: version.id }, format: :json }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#create' do
    let(:make_request) { post :create, params: { version: params } }
    let(:params) do
      {
        item_id: anime.id,
        item_type: Anime.name,
        item_diff: changes,
        user_id: user.id,
        reason: 'test'
      }
    end
    let(:role) { :user }

    describe 'common user' do
      include_context :authenticated, :user, :week_registered

      context 'common change' do
        before { make_request }
        let(:changes) { { 'russian' => ['fofofo', 'zxcvbnn'] } }

        it do
          expect(resource).to be_persisted
          expect(resource).to have_attributes params
          expect(resource).to be_pending
          expect(response).to redirect_to back_url
        end
      end

      context 'significant change' do
        let(:changes) { { 'name' => ['fofofo', 'zxcvbnn'] } }
        it { expect { make_request }.to raise_error CanCan::AccessDenied }
      end
    end

    describe 'moderator' do
      include_context :authenticated, :version_texts_moderator
      let(:changes) { { 'russian' => [nil, 'zxcvbnn'] } }
      before { make_request }

      it do
        expect(resource).to be_persisted
        expect(resource).to have_attributes params
        expect(resource).to be_accepted
        expect(response).to redirect_to back_url
      end
    end
  end

  describe '#tooltip' do
    before { get :tooltip, params: { id: version.id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    before { post :accept, params: { id: version.id } }

    it do
      expect(resource).to be_accepted
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#take' do
    before { post :take, params: { id: version.id } }

    it do
      expect(resource).to be_taken
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#reject' do
    before { post :reject, params: { id: version.id, reason: 'test' } }

    it do
      expect(resource).to be_rejected
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#accept_taken' do
    let(:version) { create :description_version, :taken, item: anime, item_diff: { russian: ['a', 'bbb'] }, user: author }
    before { post :accept_taken, params: { id: version.id } }

    it do
      expect(resource).to be_accepted
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#take_accepted' do
    let(:version) { create :description_version, :accepted, item: anime, item_diff: { russian: ['a', 'bbb'] }, user: author }
    before { post :take_accepted, params: { id: version.id } }

    it do
      expect(resource).to be_taken
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#destroy' do
    let(:make_request) { delete :destroy, params: { id: version.id } }

    context 'moderator' do
      before { make_request }
      it do
        expect(resource).to be_deleted
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end

    context 'author' do
      include_context :authenticated, :user, :week_registered
      before { make_request }

      it do
        expect(resource).to be_deleted
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end

    context 'user' do
      include_context :authenticated, :user
      let(:author) { create :user, :user }

      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
        expect(resource).to be_pending
      end
    end
  end
end
