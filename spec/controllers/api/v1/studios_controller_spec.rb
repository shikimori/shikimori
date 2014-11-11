describe Api::V1::StudiosController, :type => :controller do
  describe :show do
    let!(:studio) { create :studio }
    before { get :index, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
