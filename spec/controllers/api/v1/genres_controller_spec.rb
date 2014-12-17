describe Api::V1::GenresController do
  describe 'show' do
    let!(:genre) { create :genre }
    before { get :index, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
