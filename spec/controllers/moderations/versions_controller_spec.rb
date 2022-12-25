describe Moderations::VersionsController do
  include_context :back_redirect
  include_context :authenticated, :version_names_moderator

  let!(:version) do
    create :version,
      item: anime,
      item_diff: { russian: ['a', 'bbb'] },
      state: state,
      user: author,
      moderator: moderator
  end
  let(:author) { user }
  let(:state) { 'pending' }
  let(:anime) { create :anime }
  let(:moderator) { nil }

  describe '#index' do
    describe 'html' do
      subject! { get :index, params: { type: 'content' } }
      it { expect(response).to have_http_status :success }
    end

    describe 'json' do
      subject! { get :index, params: { type: 'content', page: 2 }, format: :json }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#show' do
    describe 'html' do
      subject! { get :show, params: { id: version.id } }
      it { expect(response).to have_http_status :success }
    end

    describe 'json' do
      subject! { get :show, params: { id: version.id }, format: :json }
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
        subject! { make_request }
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
      include_context :authenticated, :version_names_moderator
      let(:changes) { { 'russian' => [anime.russian, 'zxcvbnn'] } }
      subject! { make_request }

      it do
        expect(resource).to be_persisted
        expect(resource).to have_attributes params
        expect(resource).to be_accepted
        expect(response).to redirect_to back_url
      end
    end
  end

  describe '#tooltip' do
    subject! { get :tooltip, params: { id: version.id } }
    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    subject! { post :accept, params: { id: version.id } }

    it do
      expect(resource).to be_accepted
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#take' do
    subject! { post :take, params: { id: version.id } }

    it do
      expect(resource).to be_taken
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#reject' do
    subject! { post :reject, params: { id: version.id, reason: 'test' } }

    it do
      expect(resource).to be_rejected
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#accept_taken' do
    subject! { post :accept_taken, params: { id: version.id } }
    let(:version) do
      create :description_version, :taken,
        item: anime,
        item_diff: { russian: ['a', 'bbb'] },
        user: author
    end

    it do
      expect(resource).to be_accepted
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#take_accepted' do
    subject! { post :take_accepted, params: { id: version.id } }
    let(:version) do
      create :description_version, :accepted,
        item: anime,
        item_diff: { russian: ['a', 'bbb'] },
        user: author
    end

    it do
      expect(resource).to be_taken
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#destroy' do
    let(:make_request) { delete :destroy, params: { id: version.id } }

    context 'moderator' do
      subject! { make_request }
      it do
        expect(resource).to be_deleted
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response).to have_http_status :success
      end
    end

    context 'author' do
      include_context :authenticated, :user, :week_registered
      subject! { make_request }

      it do
        expect(resource).to be_deleted
        expect(response.content_type).to eq 'application/json; charset=utf-8'
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

  describe '#autocomplete_user' do
    let(:user) { create :user, :version_names_moderator, nickname: 'user_1' }
    let(:user_2) { create :user, nickname: 'user_2' }
    let!(:verison_2) { create :version, :accepted, user: user_2 }

    subject! do
      get :autocomplete_user,
        params: {
          search: 'user_'
        },
        xhr: true,
        format: :json
    end

    it do
      expect(collection).to eq [user, user_2]
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#autocomplete_moderator' do
    subject! do
      get :autocomplete_moderator,
        params: {
          search: moderator.nickname
        },
        xhr: true,
        format: :json
    end
    let(:state) { 'accepted' }
    let(:moderator) { user }

    it do
      expect(collection).to eq [author]
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
