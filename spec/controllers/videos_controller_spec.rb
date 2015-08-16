describe VideosController do
  include_context :authenticated, :user_changes_moderator

  let(:anime) { create :anime }
  let(:url) { 'http://youtube.com/watch?v=l1YX30AmYsA' }
  let(:name) { 'test' }
  let(:kind) { Video::PV }

  let(:json) { JSON.parse response.body }

  describe '#create' do
    include_context :back_redirect
    before { post :create, anime_id: anime.id, video: { url: url, kind: kind, name: name } }

    it do
      expect(assigns :video).to be_uploaded
      expect(assigns :video).to have_attributes(
        url: url,
        name: name,
        kind: kind,
        anime_id: anime.id,
        uploader_id: user.id
      )
      expect(assigns :video).to be_persisted

      expect(assigns :version).to be_persisted
      expect(assigns(:version).item_diff['action']).to eq(
        Versions::VideoVersion::ACTIONS[:upload])

      expect(response).to redirect_to back_url
    end
  end

  describe '#destroy' do
    let(:video) { create :video, :confirmed }
    before { post :destroy, anime_id: anime.id, id: video.id }

    it do
      expect(assigns :version).to be_persisted
      expect(assigns(:version).item_diff['action']).to eq(
        Versions::VideoVersion::ACTIONS[:delete])

      expect(response).to have_http_status :success
    end
  end
end
