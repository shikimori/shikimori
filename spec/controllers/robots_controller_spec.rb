describe RobotsController do
  describe 'anime_online' do
    subject! { get :anime_online }
    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'text/plain'
    end
  end

  describe 'shikimori' do
    before { allow(controller).to receive(:clean_host?).and_return is_clean }
    subject! { get :shikimori }

    context 'clean' do
      let(:is_clean) { true }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'text/plain'
      end
    end

    context 'not clean' do
      let(:is_clean) { false }
      it do
        is_expected.to redirect_to(
          "#{Shikimori::PROTOCOL}://#{ShikimoriDomain::CLEAN_HOST}/robots.txt"
        )
      end
    end
  end
end
