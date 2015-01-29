describe VideosController do
  include_context :authenticated, :user_changes_moderator

  let(:url) { 'http://youtube.com/watch?v=l1YX30AmYsA' }
  let(:name) { 'test' }
  let(:kind) { Video::PV }
  let(:anime_id) { create(:anime).id }

  let(:json) { JSON.parse response.body }

  describe 'create' do
    describe 'response' do
      before { post :create, id: anime_id, video: { url: url, kind: kind, name: name } }

      it { expect(response).to have_http_status :success }
      it { expect(resource).to be_uploaded }
      it { expect(resource).to have_attributes(url: url, name: name, kind: kind, anime_id: anime_id, uploader_id: user.id) }
      it { expect(resource).to be_persisted }
      it { expect(response.content_type).to eq 'application/json' }
    end

    describe 'apply' do
      before { post :create, id: anime_id, apply: 1, video: { url: url, kind: kind, name: name } }
      it { expect(resource).to be_confirmed }
      it { expect(response).to have_http_status :success }
    end

    describe 'apply wo_permissions' do
      include_context :authenticated, :user
      before { post :create, id: anime_id, apply: 1, video: { url: url, kind: kind, name: name } }
      it { expect(resource).to be_uploaded }
      it { expect(response).to have_http_status :success }
    end
  end

  describe 'destroy' do
    let(:video) { create :video, state: 'confirmed' }
    before { post :destroy, id: video.id }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }

    it 'suggest video deletion' do
      expect {
        post :destroy, id: video.id
      }.to change(UserChange.where(action: UserChange::VideoDeletion), :count).by 1
    end
  end
end
