describe Api::V1::VideosController do
  let(:anime) { create :anime }

  describe '#videos', :show_in_doc do
    let!(:video) { create :video, :confirmed, anime: anime }
    before { get :index, params: { anime_id: anime.id }, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#create' do
    include_context :authenticated, :user

    let!(:video) {}
    before { post :create, params: { anime_id: anime_id, video: video_params }, format: :json }

    let(:video_params) { { url: url, kind: kind, name: name } }
    let(:url) { 'http://youtube.com/watch?v=l1YX30AmYsA' }
    let(:name) { 'test' }
    let(:kind) { 'pv' }
    let(:anime_id) { anime.id }

    context 'new video' do
      context 'with anime', :show_in_doc do
        it do
          expect(resource).to be_persisted
          expect(resource).to be_uploaded
          expect(resource.anime).to eq anime
          expect(assigns :version).to be_persisted
          expect(assigns(:version).item).to eq anime
          expect(response).to have_http_status :success
        end
      end

      context 'wo anime' do
        let(:anime_id) { 0 }
        it do
          expect(resource).to be_persisted
          expect(resource).to be_uploaded
          expect(resource.anime).to be_nil
          expect(response).to have_http_status :success
        end
      end
    end

    context 'invalid video' do
      let(:video_params) { { kind: kind, name: name, url: '' } }
      it do
        expect(resource).to_not be_persisted
        expect(response).to have_http_status 422
      end
    end

    context 'already uploaded video' do
      let!(:video) { create :video, video_params.merge(anime: anime) }
      it do
        expect(resource).to eq video
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#destroy', :show_in_doc do
    include_context :authenticated, :user

    let(:video) { create :video, :confirmed }
    before { delete :destroy, params: { anime_id: anime.id, id: video.id } }

    it do
      expect(assigns :version).to be_persisted
      expect(assigns(:version).item_diff['action']).to eq(
        Versions::VideoVersion::Actions[:delete].to_s
      )
      expect(response).to have_http_status :success
    end
  end
end
