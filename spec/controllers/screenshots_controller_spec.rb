describe ScreenshotsController do
  include_context :authenticated, :user
  let(:anime) { create :anime }

  describe '#create' do
    let(:image) { Rack::Test::UploadedFile.new 'spec/images/anime.jpg', 'image/jpg' }
    before { post :create, anime_id: anime.id, id: anime.id, image: image }

    it do
      expect(assigns :screenshot).to be_persisted
      expect(assigns :version).to be_persisted
      expect(assigns(:version).item_diff['action']).to eq(
        Versions::ScreenshotsVersion::ACTIONS[:upload])
      expect(response).to have_http_status :success
    end
  end

  describe '#destroy' do
    let(:screenshot) { create :screenshot, status: status, anime: anime }
    before { delete :destroy, anime_id: anime.id, id: screenshot.id }

    context 'uploaded screenshot' do
      let(:status) { Screenshot::UPLOADED }

      it do
        expect(assigns :screenshot).to be_destroyed
        expect(assigns :version).to be_nil
        expect(response).to have_http_status :success
      end
    end

    context 'accepted screenshot' do
      let(:status) { }

      it do
        expect(assigns :screenshot).to be_persisted
        expect(assigns :version).to be_persisted
        expect(assigns(:version).item_diff['action']).to eq(
          Versions::ScreenshotsVersion::ACTIONS[:delete])
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#reposition' do
    include_context :back_redirect
    let!(:screenshot_1) { create :screenshot, anime: anime, position: 5 }
    let!(:screenshot_2) { create :screenshot, anime: anime, position: 9 }
    before { post :reposition, anime_id: anime.id, ids: "#{screenshot_2.id},#{screenshot_1.id}" }

    it do
      expect(assigns :version).to be_persisted
      expect(assigns(:version).item_diff['action']).to eq(
        Versions::ScreenshotsVersion::ACTIONS[:reposition])
      expect(assigns(:version).item_diff['screenshots']).to eq(
        [[screenshot_1.id, screenshot_2.id], [screenshot_2.id, screenshot_1.id]])

      expect(response).to redirect_to back_url
    end
  end
end
