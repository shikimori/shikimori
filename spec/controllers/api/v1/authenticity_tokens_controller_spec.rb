describe Api::V1::AuthenticityTokensController, :type => :controller do
  describe :show do
    before { get :show }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
