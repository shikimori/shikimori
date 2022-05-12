describe InvalidParameterErrorConcern, type: :controller do
  describe AnimesCollectionController do
    describe '#index' do
      before { get :index, params: { status: 'zxc', klass: 'anime' } }
      it { is_expected.to redirect_to animes_collection_url }
    end
  end

  describe Api::V1::AnimesController do
    describe '#index' do
      before { get :index, params: { status: 'zxc' } }
      it do
        expect(json).to eq [
          'Invalid status value "zxc". "zxc" violates constraints (included_in?([:anons, :ongoing, :released, :latest], :zxc) failed)'
        ]
        expect(response).to have_http_status 422
      end
    end
  end
end
