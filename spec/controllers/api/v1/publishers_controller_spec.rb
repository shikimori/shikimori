describe Api::V1::PublishersController do
  describe 'show' do
    let!(:publisher) { create :publisher }
    before { get :index, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
