describe Api::V1::AuthenticityTokensController do
  describe 'show' do
    before { get :show }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
