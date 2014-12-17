describe Api::V1::SectionsController do
  describe 'index' do
    let!(:section) { create :section }

    before { get :index, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
