describe RobotsController do
  describe 'shikimori' do
    before { allow(controller).to receive(:clean_host?).and_return is_clean }
    subject! { get :shikimori }

    context 'clean' do
      let(:is_clean) { true }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'text/plain; charset=utf-8'
      end
    end

    context 'not clean' do
      let(:is_clean) { false }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'text/plain; charset=utf-8'
      end
    end
  end
end
