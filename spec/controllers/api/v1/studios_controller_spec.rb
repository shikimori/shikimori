describe Api::V1::StudiosController do
  describe 'show' do
    let!(:studio) { create :studio }
    before { get :index, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
