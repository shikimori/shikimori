describe StudiosController do
  let(:studio) { create :studio }
  let!(:anime) { create :anime, studio_ids: [studio.id] }

  describe '#index' do
    before { get :index }

    it do
      expect(collection).to eq [studio]
      expect(response).to have_http_status :success
    end
  end
end
