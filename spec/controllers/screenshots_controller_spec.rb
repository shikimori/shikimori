describe ScreenshotsController do
  include_context :authenticated, :user
  let(:anime) { create :anime }

  describe '#create' do
    let(:image) { Rack::Test::UploadedFile.new 'spec/images/anime.jpg', 'image/jpg' }
    before { post :create, id: anime.id, image: image }

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

    before { delete :destroy, id: screenshot.id }

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
end
